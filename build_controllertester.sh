#!/bin/bash

# Build and install sdl2 controller tester

call_chroot "cd /home/ark &&
  cd ${CHIPSET}_core_builds &&
  git clone --recursive --depth=1 https://github.com/christianhaitian/SDL2-Controller-Tester.git &&
  cd SDL2-Controller-Tester/ &&
  make -j$(nproc) &&
  strip controllerTester &&
  cp controllerTester /usr/local/bin/ &&
  chmod 777 /usr/local/bin/controllerTester
  "

sudo mkdir -p Arkbuild/opt/system/Advanced/
sudo cp dArkOS_Tools/Advanced/"Controller Tester.sh" Arkbuild/opt/system/Advanced/.
sudo chmod 777 Arkbuild/opt/system/Advanced/"Controller Tester.sh"
call_chroot "chown -R ark:ark /opt"
