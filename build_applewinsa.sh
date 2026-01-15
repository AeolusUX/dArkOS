#!/bin/bash

# Build and install applewin standalone emulator along with sdl2-compat
if [ -f "Arkbuild_package_cache/${CHIPSET}/applewinsa.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/applewinsa.commit)" == "$(curl -s https://api.github.com/repos/audetto/AppleWin/commits/master | jq -r '.sha')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/applewinsa.tar.gz
else
	call_chroot "cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  eatmydata ./builds-alt.sh applewinsa
	  "
	sudo mkdir -p Arkbuild/opt/applewin
	sudo cp -R Arkbuild/home/ark/${CHIPSET}_core_builds/applewinsa-64/applewin Arkbuild/opt/applewin/
	sudo cp -R Arkbuild/home/ark/${CHIPSET}_core_builds/applewinsa-64/bin/ Arkbuild/opt/applewin/
	sudo cp -R Arkbuild/home/ark/${CHIPSET}_core_builds/applewinsa-64/resource/ Arkbuild/opt/applewin/
	if [ -f "Arkbuild_package_cache/${CHIPSET}/applewinsa.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/applewinsa.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/applewinsa.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/applewinsa.commit
	fi
	sudo git --git-dir=Arkbuild/home/ark/${CHIPSET}_core_builds/AppleWin/.git --work-tree=Arkbuild/home/ark/${CHIPSET}_core_builds/AppleWin rev-parse HEAD > Arkbuild_package_cache/${CHIPSET}/applewinsa.commit
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/applewinsa.tar.gz Arkbuild/opt/applewin/
fi

call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/applewin/applewin
