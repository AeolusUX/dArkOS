#!/bin/bash

echo -e "Boostraping Debian....\n\n"
# Ensure some build tools are installed and ready
sudo apt -y update
for NEEDED_TOOL in bc build-essential ccache debootstrap eatmydata gcc lib32stdc++6 libc6-i386 libncurses5-dev lzop qemu-user-static zlib1g:i386
do
  dpkg -s "$NEEDED_TOOL" &>/dev/null
  if [[ $? != "0" ]]; then
    sudo apt -y install ${NEEDED_TOOL}
    verify_action
  fi
done

#Ensure debootstrap is installed
dpkg -s "debootstrap" &>/dev/null
if [[ $? != "0" ]]; then
  sudo apt -y update
  sudo apt -y install debootstrap
fi

# Create ccache if it does not exist already
if [ ! -d "Arkbuild_ccache" ]; then
  mkdir Arkbuild_ccache
fi
export CCACHE_DIR=${PWD}/Arkbuild_ccache
sudo /usr/sbin/update-ccache-symlinks
[ -z $(echo $PATH | grep ccache) ] && export PATH=/usr/lib/ccache:$PATH


# Bootstrap base system
sudo eatmydata debootstrap --no-check-gpg --include=eatmydata --resolve-deps --arch=arm64 --foreign bookworm Arkbuild http://deb.debian.org/debian/
sudo cp /usr/bin/qemu-aarch64-static Arkbuild/usr/bin/
sudo chroot Arkbuild/ apt-get -y install ccache eatmydata
sudo chroot Arkbuild/ eatmydata /debootstrap/debootstrap --second-stage

# Bind essential host filesystems into chroot for networking
sudo mount --bind /dev Arkbuild/dev
sudo mount -t devpts none Arkbuild/dev/pts -o newinstance,ptmxmode=0666
#sudo mount --bind /dev/pts Arkbuild/dev/pts -o newinstance,ptmxmode=0666
sudo mount --bind /proc Arkbuild/proc
sudo mount --bind /sys Arkbuild/sys
echo -e "nameserver 8.8.8.8\nnameserver 1.1.1.1" | sudo tee Arkbuild/etc/resolv.conf > /dev/null

# Avoid service autostarts
echo "exit 101" | sudo tee Arkbuild/usr/sbin/policy-rc.d > /dev/null
sudo chmod 0755 Arkbuild/usr/sbin/policy-rc.d
sudo chroot Arkbuild/ mount -t proc proc /proc

# Enable armhf architecture and update
sudo chroot Arkbuild/ dpkg --add-architecture armhf
sudo chroot Arkbuild/ eatmydata apt-get -y update
sudo chroot Arkbuild/ eatmydata apt-get -y install libc6:armhf liblzma5:armhf libasound2t64:armhf libfreetype6:armhf libxkbcommon-x11-0:armhf libudev1:armhf libudev0:armhf libgbm1:armhf libstdc++6:armhf

# Install base runtime packages
sudo chroot Arkbuild/ eatmydata apt-get install -y initramfs-tools sudo evtest network-manager systemd-sysv locales locales-all ssh dosfstools fluidsynth
sudo chroot Arkbuild/ eatmydata apt-get install -y python3 python3-pip
echo -e "export LC_All=C.UTF-8" | sudo tee -a Arkbuild/root/.bashrc > /dev/null
sudo chroot Arkbuild/ bash -c "update-locale"
sudo chroot Arkbuild/ systemctl enable NetworkManager

# Install libmali, DRM, and GBM libraries for rk3326
sudo chroot Arkbuild/ eatmydata apt-get install -y libdrm-dev libgbm1

# Place libmali manually (assumes you have libmali.so or mali drivers ready)
for ARCHITECTURE in aarch64-linux-gnu arm-linux-gnueabihf
do
  if [ "$ARCHITECTURE" == "aarch64-linux-gnu" ]; then
    FOLDER="aarch64"
  else
    FOLDER="armhf"
  fi
  sudo mkdir -p Arkbuild/usr/lib/${ARCHITECTURE}/
  wget -t 3 -T 60 --no-check-certificate https://github.com/christianhaitian/rk3326_core_builds/raw/refs/heads/rk3326/mali/${FOLDER}/libmali-bifrost-g31-rxp0-gbm.so
  sudo mv libmali-bifrost-g31-rxp0-gbm.so Arkbuild/usr/lib/${ARCHITECTURE}/.
  whichmali="libmali-bifrost-g31-rxp0-gbm.so"
  cd Arkbuild/usr/lib/${ARCHITECTURE}
  sudo ln -sf ${whichmali} libMali.so
  for LIB in libEGL.so libEGL.so.1 libGLES_CM.so libGLES_CM.so.1 libGLESv1_CM.so libGLESv1_CM.so.1 libGLESv1_CM.so.1.1.0 libGLESv2.so libGLESv2.so.2 libGLESv2.so.2.0.0 libGLESv2.so.2.1.0 libGLESv3.so libGLESv3.so.3 libgbm.so libgbm.so.1 libgbm.so.1.0.0 libmali.so libmali.so.1 libMaliOpenCL.so libOpenCL.so libwayland-egl.so libwayland-egl.so.1 libwayland-egl.so.1.0.0
  do
    sudo rm -fv ${LIB}
    sudo ln -sfv libMali.so ${LIB}
  done
  cd ../../../../
done
sudo chroot Arkbuild/ ldconfig
sleep 10
setup_ark_user
sleep 10
echo -e "Generating /etc/fstab"
echo -e "LABEL=ROOTFS / ext4 defaults, noatime 0 1
LABEL=BOOT /boot vfat defaults 0 0
LABEL=EASYROMS /roms vfat defaults,auto,umask=000,uid=1000,gid=1000,noatime 0 0" | sudo tee Arkbuild/etc/fstab
echo -e "Generating 10-standard.rules for udev"
echo -e "# Rules
KERNEL==\"mali0\", GROUP=\"video\", MODE=\"0660\"
KERNEL==\"rga\", GROUP=\"video\", MODE=\"0660\"
ACTION==\"add\", SUBSYSTEM==\"backlight\", RUN+=\"/bin/chgrp video /sys/class/backlight/%k/brightness\"
ACTION==\"add\", SUBSYSTEM==\"backlight\", RUN+=\"/bin/chmod g+w /sys/class/backlight/%k/brightness\"" | sudo tee Arkbuild/etc/udev/rules.d/10-standard.rules
echo -e "Generating 40-usb_modeswitch.rules for udev"
echo -e "# Rules
ACTION!=\"add|change\", GOTO=\"end_modeswitch\"

# Atheros Wireless / Netgear WNDA3200
ATTRS{idVendor}==\"0cf3\", ATTRS{idProduct}==\"20ff\", RUN+=\"/usr/bin/eject '/dev/%k'\"

# Realtek RTL8821CU chipset 802.11ac NIC
#   initial cdrom mode 0bda:1a2b, wlan mode 0bda:c811
# Odroid WiFi Module 5B
#   initial cdrom mode 0bda:1a2b, wlan mode 0bda:c820
ATTR{idVendor}==\"0bda\", ATTR{idProduct}==\"1a2b\", RUN+=\"/usr/sbin/usb_modeswitch -K -v 0bda -p 1a2b\"
ATTR{idVendor}==\"0bda\", ATTR{idProduct}==\"c811\", RUN+=\"/usr/sbin/usb_modeswitch -K -v 0bda -p c811\"

LABEL=\"end_modeswitch\"" | sudo tee Arkbuild/etc/udev/rules.d/40-usb_modeswitch.rules
sudo chroot Arkbuild/ sync
sleep 5
sudo chroot Arkbuild/ umount /proc

