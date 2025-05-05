#!/bin/bash

# Build and install PPSSPP standalone emulator
sudo chroot Arkbuild/ bash -c "cd /home/ark &&
  cd rk3326_core_builds &&
  chmod 777 builds-alt.sh &&
  ./builds-alt.sh ppsspp
  "
sudo mkdir -p Arkbuild/opt/ppsspp
sudo cp -Ra Arkbuild/home/ark/rk3326_core_builds/ppsspp/build/assets/ Arkbuild/opt/ppsspp/
sudo cp ppsspp/gamecontrollerdb.txt Arkbuild/opt/ppsspp/assets/
sudo cp ppsspp/ppsspp.sh Arkbuild/usr/local/bin/
sudo cp ppsspp/ppsspphotkey.service Arkbuild/etc/systemd/system/
sudo cp ppsspp/ppssppkeydemon.py.rgb10 Arkbuild/usr/local/bin/ppssppkeydemon.py
sudo cp -R ppsspp/configs/backupforromsfolder/ Arkbuild/opt/ppsspp/
sudo cp ppsspp/controls.ini.rgb10 Arkbuild/opt/ppsspp/backupforromsfolder/ppsspp/PSP/SYSTEM/controls.ini
sudo cp ppsspp/ppsspp.ini.rgb10 Arkbuild/opt/ppsspp/backupforromsfolder/ppsspp/PSP/SYSTEM/ppsspp.ini
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/ppsspp/LICENSE.TXT/ Arkbuild/opt/ppsspp/
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/ppsspp/build/PPSSPPSDL Arkbuild/opt/ppsspp/
sudo chroot Arkbuild/ bash -c "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/ppsspp/PPSSPPSDL
sudo chmod 777 Arkbuild/usr/local/bin/ppssppkeydemon.py
sudo chmod 777 Arkbuild/usr/local/bin/ppsspp.sh
