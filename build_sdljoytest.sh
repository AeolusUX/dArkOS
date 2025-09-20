#!/bin/bash

# Build and install sdljoytest from EmuElec

call_chroot "cd /home/ark &&
  cd ${CHIPSET}_core_builds &&
  git clone --recursive --depth=1 https://github.com/christianhaitian/sdljoytest.git &&
  cd sdljoytest/ &&
  make -j$(nproc) &&
  strip gamepad_info map_gamepad_SDL2 test_gamepad_SDL2 &&
  cp gamepad_info /usr/local/bin/sdljoyinfo &&
  cp map_gamepad /usr/local/bin/sdljoymap &&
  cp test_gamepad_SDL2 /usr/local/bin/sdljoytest &&
  chmod 777 /usr/local/bin/{sdljoyinfo,sdljoymap,sdljoytest}
  "
