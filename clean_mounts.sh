#!/bin/bash

# Unmount chroot binds
remove_arkbuild
remove_arkbuild32
sudo umount $PWD/Arkbuild_ccache
rm -rf mnt
sudo rm -f "${FILESYSTEM}"
sudo rm -rf $KERNEL_SRC
