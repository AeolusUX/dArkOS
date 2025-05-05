#!/bin/bash

# Build and install SCUMMVM standalone emulator
sudo chroot Arkbuild/ bash -c "cd /home/ark &&
  cd rk3326_core_builds &&
  chmod 777 builds-alt.sh &&
  ./builds-alt.sh scummvm
  "
sudo mkdir -p Arkbuild/opt/scummvm
sudo mkdir -p Arkbuild/home/ark/.config/scummvm
sudo cp -Ra Arkbuild/home/ark/rk3326_core_builds/scummvm/extra/ Arkbuild/opt/scummvm/
sudo cp -Ra Arkbuild/home/ark/rk3326_core_builds/scummvm/themes/ Arkbuild/opt/scummvm/
sudo cp -Ra Arkbuild/home/ark/rk3326_core_builds/scummvm/LICENSES/ Arkbuild/opt/scummvm/
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/scummvm/scummvm Arkbuild/opt/scummvm/
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/scummvm/AUTHORS Arkbuild/opt/scummvm/
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/scummvm/COPYING Arkbuild/opt/scummvm/
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/scummvm/COPYRIGHT Arkbuild/opt/scummvm/
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/scummvm/NEWS.md Arkbuild/opt/scummvm/
sudo cp -a Arkbuild/home/ark/rk3326_core_builds/scummvm/README.md Arkbuild/opt/scummvm/
sudo chroot Arkbuild/ bash -c "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/scummvm/scummvm
sudo cp scummvm/scummvmkeydemon.py.rgb10 Arkbuild/usr/local/bin/scummvmkeydemon.py
sudo cp scummvm/configs/scummvm.ini.rgb10 Arkbuild/home/ark/.config/scummvm/scummvm.ini
sudo chroot Arkbuild/ bash -c "chown -R ark:ark /home/ark/.config/"
sudo cp scummvm/scummvm.sh Arkbuild/usr/local/bin/scummvm.sh
sudo chmod 777 Arkbuild/usr/local/bin/scummvm.sh
sudo chmod 777 Arkbuild/usr/local/bin/scummvmkeydemon.py