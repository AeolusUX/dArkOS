#!/bin/bash

# Unmount chroot binds
remove_arkbuild
remove_arkbuild32
if grep -qs "$PWD/Arkbuild_ccache" /proc/mounts; then
  sudo umount $PWD/Arkbuild_ccache
fi
if grep -qs "${mountpoint}" /proc/mounts; then
  sync ${mountpoint}
  STUBBORN_LOOP="$(grep -s "${mountpoint}" /proc/mounts | grep -oP "^\\S+")"
  sudo umount -l -f ${mountpoint}
  sudo losetup -d ${STUBBORN_LOOP}
fi
sudo rm -rf mnt
sudo rm -f "${FILESYSTEM}"
sudo rm -rf $KERNEL_SRC
if [ ! -z "${LOOP_DEV}" ]; then
  sudo losetup -d ${LOOP_DEV}
fi
