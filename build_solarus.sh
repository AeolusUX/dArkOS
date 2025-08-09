#!/bin/bash

# Build and install solarus standalone emulator along with sdl2-compat
call_chroot "cd /home/ark &&
  cd ${CHIPSET}_core_builds &&
  chmod 777 builds-alt.sh &&
  eatmydata ./builds-alt.sh solarus
  "
sudo mkdir -p Arkbuild/opt/solarus
sudo cp -R Arkbuild/home/ark/${CHIPSET}_core_builds/solarus64/* Arkbuild/opt/solarus/
sudo cp solarus/configs/${UNIT}/pads.ini Arkbuild/opt/solarus/
sudo cp solarus/scripts/solarus.sh Arkbuild/usr/local/bin/
sudo chmod 777 Arkbuild/usr/local/bin/solarus.sh
call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/solarus/solarus-run
