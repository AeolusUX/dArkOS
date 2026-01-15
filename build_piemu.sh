#!/bin/bash

# Build and install piemu standalone emulator along with sdl2-compat
if [ -f "Arkbuild_package_cache/${CHIPSET}/piemu.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/piemu.commit)" == "$(curl -s https://api.github.com/repos/YonKuma/piemu/commits/modernize | jq -r '.sha')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/piemu.tar.gz
else
	call_chroot "cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  eatmydata ./builds-alt.sh piemusa
	  "
	sudo mkdir -p Arkbuild/opt/piemu
	sudo cp -a Arkbuild/home/ark/${CHIPSET}_core_builds/piemusa64/* Arkbuild/opt/piemu/
	if [ -f "Arkbuild_package_cache/${CHIPSET}/piemu.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/piemu.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/piemu.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/piemu.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/piemu.tar.gz Arkbuild/opt/piemu/
	sudo git --git-dir=Arkbuild/home/ark/${CHIPSET}_core_builds/piemu/.git --work-tree=Arkbuild/home/ark/${CHIPSET}_core_builds/piemu rev-parse HEAD > Arkbuild_package_cache/${CHIPSET}/piemu.commit
fi

sudo cp piemu/scripts/piemu_run.sh Arkbuild/usr/local/bin/
call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/piemu/*
sudo chmod 777 Arkbuild/usr/local/bin/piemu_run.sh