#!/bin/bash

# Unmount chroot binds
remove_arkbuild
remove_arkbuild32
if grep -qs "$PWD/Arkbuild_ccache" /proc/mounts; then
  sudo umount $PWD/Arkbuild_ccache
fi
rm -rf mnt
sudo rm -f "${FILESYSTEM}"
sudo rm -rf $KERNEL_SRC
if [ ! -z "${LOOP_DEV}" ]; then
  sudo losetup -d ${LOOP_DEV}
fi
