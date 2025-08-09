#!/bin/bash

# Create extlinux.conf
sudo mkdir -p ${mountpoint}/extlinux
cat <<EOF | sudo tee ${mountpoint}/extlinux/extlinux.conf
LABEL ArkOS
  LINUX /Image
  FDT /${UNIT_DTB}.dtb
  APPEND root=/dev/mmcblk1p4 initrd=/uInitrd rootwait rw fsck.repair=yes quiet splash net.ifnames=0 console=tty1 plymouth.ignore-serial-consoles consoleblank=0 loglevel=0 video=HDMI-A-1:1280x720@60
EOF

#sudo cp logo.bmp ${mountpoint}/
sudo cp optional/* ${mountpoint}/

# Tell systemd to ignore PowerKey presses.  Let the Global Hotkey daemon handle that
echo "HandlePowerKey=ignore" | sudo tee -a Arkbuild/etc/systemd/logind.conf

# Add some important exports to .bashrc for user ark
echo "export PATH=\"\$PATH:/usr/sbin\"" | sudo tee -a Arkbuild/home/ark/.bashrc
sudo chroot Arkbuild/ bash -c "chown ark:ark /home/ark/.bashrc"

# Set the name in the hostname and add it to the hosts file
if [[ "$UNIT" == *"353"* ]] || [[ "$UNIT" == *"503"* ]]; then
  NAME="rg${UNIT}"
else
  NAME="${UNIT}"
fi
echo "$NAME" | sudo tee Arkbuild/etc/hostname
echo -e "# This host address\n127.0.1.1\t${NAME}" | sudo tee -a Arkbuild/etc/hosts
#sudo sed -i "0,/localhost/s//localhost ${NAME}/1" Arkbuild/etc/hosts

# Copy the necessary .asoundrc file for proper audio in emulationstation and emulators
sudo cp audio/.asoundrc.${CHIPSET} Arkbuild/home/ark/.asoundrc
sudo cp audio/.asoundrcbak.${CHIPSET} Arkbuild/home/ark/.asoundrcbak
sudo cp audio/.asoundrcbt.${CHIPSET} Arkbuild/home/ark/.asoundrcbt
sudo chown ark:ark Arkbuild/home/ark/.asoundrc*

# Sleep script and set default SuspendState to freeze
sudo mkdir -p Arkbuild/usr/lib/systemd/system-sleep
sudo cp scripts/sleep.${CHIPSET} Arkbuild/usr/lib/systemd/system-sleep/sleep
sudo chmod 777 Arkbuild/usr/lib/systemd/system-sleep/sleep
sudo sed -i "/SuspendState\=/c\SuspendState\=freeze" Arkbuild/etc/systemd/sleep.conf

# Set performance governor to ondemand on boot
sudo chroot Arkbuild/ bash -c "(crontab -l 2>/dev/null; echo \"@reboot /usr/local/bin/perfnorm quiet &\") | crontab -"

# Set DRM on boot
sudo chroot Arkbuild/ bash -c "(crontab -l 2>/dev/null; echo \"@reboot /usr/local/bin/hdmi-test.sh &\") | crontab -"

# Restore screen colors, saturation and such on boot
#sudo chroot Arkbuild/ bash -c "(crontab -l 2>/dev/null; echo \"@reboot /usr/local/bin/panel_set.sh RestoreSettings &\") | crontab -"

# Find and record panel id on boot
sudo chroot Arkbuild/ bash -c "(crontab -l 2>/dev/null; echo \"@reboot dmesg | grep 'panel id' > /home/ark/.config/.panel_info &\") | crontab -"

# Speaker Toggle to set audio output to SPK on boot
sudo mkdir -p Arkbuild/usr/local/bin
sudo cp scripts/spktoggle.sh Arkbuild/usr/local/bin/
sudo chmod 777 Arkbuild/usr/local/bin/spktoggle.sh
sudo chroot Arkbuild/ bash -c "(crontab -l 2>/dev/null; echo \"@reboot /usr/local/bin/spktoggle.sh &\") | crontab -"
#sudo cp scripts/audiopath.service Arkbuild/etc/systemd/system/audiopath.service
sudo cp scripts/audiostate.service Arkbuild/etc/systemd/system/audiostate.service
#sudo chroot Arkbuild/ bash -c "systemctl enable audiopath"
sudo chroot Arkbuild/ bash -c "systemctl enable audiostate"

# Copy necessary tools for expansion of ROOTFS and convert fat32 games partition to exfat on initial boot
sudo cp scripts/expandtoexfat.sh.${CHIPSET} ${mountpoint}/expandtoexfat.sh
sudo cp scripts/firstboot.sh ${mountpoint}/firstboot.sh
#sudo cp scripts/fstab.exfat.${CHIPSET} ${mountpoint}/fstab.exfat
sudo cp scripts/firstboot.service Arkbuild/etc/systemd/system/firstboot.service
sudo chroot Arkbuild/ bash -c "systemctl enable firstboot"

# Add hotkeydaemon service and python script
sudo cp hotkeydaemon/killer_daemon.service Arkbuild/etc/systemd/system/killer_daemon.service
sudo cp hotkeydaemon/killer_daemon.py Arkbuild/usr/local/bin/killer_daemon.py
sudo chmod 777 Arkbuild/usr/local/bin/killer_daemon.py

# Add amiga script
sudo cp amiga/amiga.sh Arkbuild/usr/local/bin/

#Generate fstab to be used after EASYROMS expansion
cat <<EOF | sudo tee ${mountpoint}/fstab.exfat
/dev/mmcblk1p4  /  ${ROOT_FILESYSTEM_FORMAT} ${ROOT_FILESYSTEM_MOUNT_OPTIONS} 0 0

/dev/mmcblk1p3 /boot vfat defaults,noatime 0 0
/dev/mmcblk1p5 /roms exfat defaults,auto,umask=000,uid=1002,gid=1002,noatime 0 0
/roms/tools /opt/system/Tools none nofail,x-systemd.device-timeout=7,bind
EOF

# Disable getty on tty0 and tty1
sudo chroot Arkbuild/ bash -c "systemctl disable getty@tty0.service getty@tty1.service"

# Disable some other unneeded services
sudo chroot Arkbuild/ bash -c "systemctl disable ModemManager polkit"

# Disable ssh service from automatically starting
sudo chroot Arkbuild/ bash -c "systemctl disable ssh"

# Update Messaage of the Day
sudo cp -f scripts/00-header Arkbuild/etc/update-motd.d/00-header
sudo cp -f scripts/10-help-text Arkbuild/etc/update-motd.d/10-help-text
sudo rm -f Arkbuild/etc/motd
sudo chmod 777 Arkbuild/etc/update-motd.d/*

# Disable some unneeded interfaces in NetworkManager
cat <<EOF | sudo tee -a Arkbuild/etc/NetworkManager/NetworkManager.conf

[device]
wifi.scan-rand-mac-address=no

[keyfile]
unmanaged-devices=interface-name:p2p0;interface-name:ap0
EOF

# Default set timezone to New York
sudo chroot Arkbuild/ bash -c "ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime"

# Various tools available through Options added here
sudo mkdir -p Arkbuild/opt/system/Advanced
sudo cp dArkOS_Tools/*.sh Arkbuild/opt/system/
sudo cp dArkOS_Tools/${CHIPSET}/*.sh Arkbuild/opt/system/Advanced/
sudo cp dArkOS_Tools/Advanced/*.sh Arkbuild/opt/system/Advanced/
sudo chroot Arkbuild/ bash -c "chown -R ark:ark /opt"
sudo chmod -R 777 Arkbuild/opt/system/

# Copy performance scripts
sudo cp scripts/perf* Arkbuild/usr/local/bin/

# Disable power saving for 8821cs wifi chip
cat <<EOF | sudo tee Arkbuild/etc/modprobe.d/8821cs.conf
# Disable power saving
options 8821cs rtw_power_mgnt=0 rtw_enusbss=0 rtw_ips_mode=0
EOF

# Add USB DAC Support
echo -e "Generating 20-usb-alsa.rules udev for usb dac support"
echo -e "KERNEL==\"controlC[0-9]*\", DRIVERS==\"usb\", SYMLINK=\"snd/controlC7\"" | sudo tee Arkbuild/etc/udev/rules.d/20-usb-alsa.rules
sudo chroot Arkbuild/ bash -c "(crontab -l 2>/dev/null; echo \"@reboot /usr/local/bin/checknswitchforusbdac.sh &\") | crontab -"

# Copy various other backend tools
sudo cp -R scripts/.asoundbackup/ Arkbuild/usr/local/bin/
sudo cp -R scripts/freej2me_files/ Arkbuild/usr/local/bin/
sudo cp scripts/controllerTester Arkbuild/usr/local/bin/
sudo cp scripts/round_end.wav Arkbuild/usr/local/bin/
sudo cp scripts/checkbrightonboot Arkbuild/usr/local/bin/
sudo cp scripts/current_* Arkbuild/usr/local/bin/
sudo cp scripts/finish.sh Arkbuild/usr/local/bin/
sudo cp scripts/pause.sh Arkbuild/usr/local/bin/
sudo cp scripts/speak_bat_life.sh Arkbuild/usr/local/bin/
sudo cp scripts/spktoggle.sh Arkbuild/usr/local/bin/
sudo cp scripts/volume.sh Arkbuild/usr/local/bin/
sudo cp scripts/${CHIPSET}/* Arkbuild/usr/local/bin/
sudo cp scripts/timezones Arkbuild/usr/local/bin/
sudo cp global/* Arkbuild/usr/local/bin/
sudo cp device/${CHIPSET}/uboot.img.anbernic Arkbuild/usr/local/bin/

# Make all scripts in /usr/local/bin executable, world style
sudo chmod 777 Arkbuild/usr/local/bin/*

# Link themes folder to /roms/themes and clone some themes to the folder
sudo rm -rf Arkbuild/etc/emulationstation/themes/
sudo chroot Arkbuild/ bash -c "ln -sfv /roms/themes/ /etc/emulationstation/themes"

# Set launchimage to PIC mode
sudo chroot Arkbuild/ touch /home/ark/.config/.GameLoadingIModePIC

# Set default volume
sudo cp audio/asound.state.${CHIPSET} Arkbuild/var/local/asound.state

# Set SDL Video Driver for bash
echo "export SDL_VIDEO_EGL_DRIVER=libEGL.so" | sudo tee Arkbuild/etc/profile.d/SDL_VIDEO.sh

# Set device name 
echo "$NAME" | sudo tee Arkbuild/home/ark/.config/.DEVICE

# Configure default samba share setup
cat <<EOF | sudo tee -a Arkbuild/etc/samba/smb.conf
[roms]
   comment = ROMS
   path = /roms
   browsable = yes
   read only = no
   map archive = no
   map system = no
   map hidden = no
   guest ok = yes
   read list = guest

[opt]
   comment = OPT
   path = /opt
   browsable = yes
   read only = no
   map archive = no
   map system = no
   map hidden = no
   guest ok = yes
   read list = guest

[ark]
   comment = ark
   path = /home/ark
   browsable = yes
   read only = no
   map archive = no
   map system = no
   map hidden = no
   guest ok = yes
   read list = guest
EOF
sudo chroot Arkbuild/ bash -c "systemctl disable smbd"
sudo chroot Arkbuild/ bash -c "systemctl disable nmbd"

# Set distro identification and version
sudo mkdir -p Arkbuild/usr/share/plymouth/themes/
cat <<EOF | sudo tee Arkbuild/usr/share/plymouth/themes/text.plymouth
title=dArkOS (${BUILD_DATE})
EOF
echo "${BUILD_DATE}" | sudo tee Arkbuild/home/ark/.config/.VERSION

# Set boot up welcome text with distro and version
sudo cp scripts/boot_text.sh Arkbuild/usr/local/bin/
sudo chmod 777 Arkbuild/usr/local/bin/boot_text.sh
sudo cp scripts/welcome-message.service Arkbuild/etc/systemd/system/welcome-message.service
sudo chroot Arkbuild/ bash -c "systemctl enable welcome-message"

# Set the ownver of the ark folder and all sub content to ark
sudo chroot Arkbuild/ bash -c "chown -R ark:ark /home/ark"

# Clone some themes to the tempthemes folder
sudo mkdir Arkbuild/tempthemes
if [ "$UNIT" == "rgb30" ]; then
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-freeplay.git Arkbuild/tempthemes/es-theme-freeplay
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-sagabox.git Arkbuild/tempthemes/es-theme-sagabox
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-switch.git Arkbuild/tempthemes/es-theme-switch
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-simply-basic.git Arkbuild/tempthemes/es-theme-simply-basic
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-sagamodern.git Arkbuild/tempthemes/es-theme-sagamodern
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-saganx.git Arkbuild/tempthemes/es-theme-saganx
  sudo git clone --depth=1 https://github.com/dani7959/es-theme-replica.git Arkbuild/tempthemes/es-theme-replica
else
  if [[ "$UNIT" == *"rgb10"* ]] || [[ "$UNIT" == "rk2020" ]] || [[ "$UNIT" == *"oga"* ]]; then
    sudo git clone --depth=1 https://github.com/pix33l/es-theme-pixui.git
  fi
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-freeplay.git Arkbuild/tempthemes/es-theme-freeplay
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-minimal-arkos.git Arkbuild/tempthemes/es-theme-minimal-arkos
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-nes-box.git Arkbuild/tempthemes/es-theme-nes-box
  sudo git clone --depth=1 https://github.com/Jetup13/es-theme-switch.git Arkbuild/tempthemes/es-theme-switch
  sudo git clone --depth=1 https://github.com/dani7959/es-theme-replica.git Arkbuild/tempthemes/es-theme-replica
fi

sync
sudo umount -l ${mountpoint}
#while true; do
  #sleep 1
  #if [[ -z "$(fuser -c ${mountpoint})" ]]; then
    #break
  #fi
  #echo "${mountpoint} is still in use.  Attempting to force close processes using it..."
  #sudo fuser -ckv -9 ${mountpoint}
#done

fat32_mountpoint=mnt/roms
mkdir -p ${fat32_mountpoint}
sudo mkdir -p Arkbuild/roms
while read GAME_SYSTEM; do
  if [[ ! "$GAME_SYSTEM" =~ ^# ]]; then
    echo -e "Creating ${fat32_mountpoint}/${GAME_SYSTEM}\n"
    sudo mkdir -p ${fat32_mountpoint}/${GAME_SYSTEM}
  fi
done <game_systems.txt

# Copy default game launch images
sudo cp launchimages/loading.ascii.${UNIT} ${fat32_mountpoint}/launchimages/loading.ascii
sudo cp launchimages/loading.jpg.${UNIT} ${fat32_mountpoint}/launchimages/loading.jpg

# Copy various tools to roms folders
sudo cp -a ecwolf/Scan* ${fat32_mountpoint}/wolf/
sudo cp -a scummvm/scripts/Scan* ${fat32_mountpoint}/scummvm/
sudo cp -a hypseus-singe/scripts/Scan* ${fat32_mountpoint}/scummvm/
sudo cp -a scummvm/scripts/menu.scummvm ${fat32_mountpoint}/scummvm/

# Clone some themes to the roms/themes folder
sudo git clone https://github.com/Jetup13/es-theme-nes-box.git ${fat32_mountpoint}/themes/es-theme-nes-box
sync

# Create roms.tar for use after exfat partition creation
sudo tar -C mnt/ -cvf Arkbuild/roms.tar roms

# Remove and cleanup fat32 roms mountpoint
sudo chmod -R 755 ${fat32_mountpoint}
sync

sudo rm -rf ${fat32_mountpoint}
