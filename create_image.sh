#!/bin/bash

xz --keep -z -9 -T0 ArkOS_RGB10.img
if [ -d "/media/sf_VMShare" ]; then
  sudo rm -f /media/sf_VMShare/RGB10\ Boot/ArkOS_RGB10.img*
  sudo cp ArkOS_RGB10.img /media/sf_VMShare/RGB10\ Boot/ArkOS_RGB10.img
  mv ArkOS_RGB10.img.xz /media/sf_VMShare/RGB10\ Boot/
fi
