#!/bin/bash

# Build and install Kodi
KODI_VERSION_TAG=21.3-Omega
# Install additional Kodi build dependencies
if test -z "$(cat Arkbuild/etc/apt/sources.list | grep ${DEBIAN_CODE_NAME}-backports)"
then
    echo "deb http://deb.debian.org/debian ${DEBIAN_CODE_NAME}-backports main" | sudo tee -a Arkbuild/etc/apt/sources.list
    call_chroot "apt -y update"
fi

while read KODI_NEEDED_DEV_PACKAGE; do
  if [[ ! "$KODI_NEEDED_DEV_PACKAGE" =~ ^# ]]; then
    install_package 64 "${KODI_NEEDED_DEV_PACKAGE}"
  fi
done <kodi_needed_dev_packages.txt
call_chroot "cd /home/ark &&
  mkdir -p kodi &&
  cd kodi &&
  git clone --recursive https://github.com/christianhaitian/kodi-install &&
  cd kodi-install &&
  sed -i '/\/home\/kodi/s//\/home\/ark\/kodi/' configuration.sh &&
  chmod 777 ArkOS-Kodi-Build-alt.sh &&
  ./ArkOS-Kodi-Build-alt.sh ${KODI_VERSION_TAG}
  "
sudo rm -rf Arkbuild/home/ark/kodi
sudo cp -R kodi/userdata/ Arkbuild/opt/kodi/
call_chroot "chown -R ark:ark /opt/kodi/"
sudo cp kodi/scripts/Kodi.sh Arkbuild/usr/local/bin/
sudo chmod 777 Arkbuild/usr/local/bin/Kodi.sh

if [[ "$UNIT" != *"503"* ]]; then
  sudo sed -i '/<res width\="1920" height\="1440" aspect\="4:3"/s//<res width\="1623" height\="1180" aspect\="4:3"/g' Arkbuild/opt/kodi/share/kodi/addons/skin.estuary/addon.xml
fi

while read KODI_NEEDED_DEV_PACKAGE; do
  if [[ ! "$KODI_NEEDED_DEV_PACKAGE" =~ ^# ]] && [[ "$KODI_NEEDED_DEV_PACKAGE" == *"-dev"* ]]; then
    call_chroot "apt remove -y $KODI_NEEDED_DEV_PACKAGE"
  fi
done <kodi_needed_dev_packages.txt
