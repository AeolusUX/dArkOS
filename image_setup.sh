#!/bin/bash

echo -e "Setup the Image file...\n\n"
sleep 10
# Ensure some build tools are installed and ready
sudo apt -y update
for NEEDED_TOOL in bc build-essential debootstrap eatmydata gcc lib32stdc++6 libc6-i386 libncurses5-dev lzop qemu-user-static zlib1g:i386
do
  dpkg -s "$NEEDED_TOOL" &>/dev/null
  if [[ $? != "0" ]]; then
    sudo apt -y install ${NEEDED_TOOL}
    verify_action
  fi
done

# Verify the correct toolchain is available
if [ ! -f "toolchains/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu" ]; then
  mkdir -p toolchains
  wget https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/aarch64-linux-gnu/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz
  verify_action
  tar Jxvf gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz -C toolchains/
  rm gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu.tar.xz
fi

# Setup the necessary exports
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
export PATH=toolchains/gcc-linaro-6.3.1-2017.05-x86_64_aarch64-linux-gnu/bin/:$PATH

# Image creation
DISK="ArkOS_RGB10.img"
dd if=/dev/zero of="${DISK}" bs=1M count=0 seek="${DISK_SIZE}" conv=fsync
parted -s "${DISK}" mklabel msdos
parted -s "${DISK}" -a min unit s mkpart primary fat32 ${SYSTEM_PART_START} ${SYSTEM_PART_END}
parted -s "${DISK}" set 1 boot on
parted -s "${DISK}" -a min unit s mkpart primary ext4 ${STORAGE_PART_START} ${STORAGE_PART_END}
parted -s "${DISK}" set 2 lba off
parted -s "${DISK}" -a min unit s mkpart primary fat32 ${ROM_PART_START} ${ROM_PART_END}
sync



# Build uboot and install it to the image
git clone https://github.com/christianhaitian/u-boot-rk3326
cd u-boot-rk3326
./make.sh odroidgoa

dd if="sd_fuse/idbloader.img" of="../${DISK}" bs=512 seek=64 conv=sync,noerror,notrunc
dd if="sd_fuse/uboot.img" of="../${DISK}" bs=512 seek=16384 conv=sync,noerror,notrunc
dd if="sd_fuse/trust.img" of="../${DISK}" bs=512 seek=24576 conv=sync,noerror,notrunc

cd ..
rm -rf u-boot-rk3326
