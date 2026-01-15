#!/bin/bash

# Build and install fake08 standalone emulator
if [ -f "Arkbuild_package_cache/${CHIPSET}/fake08.tar.gz" ] && [ "$(cat Arkbuild_package_cache/${CHIPSET}/fake08.commit)" == "$(curl -s https://api.github.com/repos/jtothebell/fake-08/commits/master | jq -r '.sha')" ]; then
    sudo tar -xvzpf Arkbuild_package_cache/${CHIPSET}/fake08.tar.gz
else
	call_chroot "source /root/.bashrc && cd /home/ark &&
	  cd ${CHIPSET}_core_builds &&
	  chmod 777 builds-alt.sh &&
	  eatmydata ./builds-alt.sh fake08sa &&
	  mkdir -p /opt/fake08 &&
	  cp fake08sa-64/fake08 /opt/fake08/
	  "
	if [ -f "Arkbuild_package_cache/${CHIPSET}/fake08.tar.gz" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/fake08.tar.gz
	fi
	if [ -f "Arkbuild_package_cache/${CHIPSET}/fake08.commit" ]; then
	  sudo rm -f Arkbuild_package_cache/${CHIPSET}/fake08.commit
	fi
	sudo tar -czpf Arkbuild_package_cache/${CHIPSET}/fake08.tar.gz Arkbuild/opt/fake08/
	sudo git --git-dir=Arkbuild/home/ark/${CHIPSET}_core_builds/fake-08sa/.git --work-tree=Arkbuild/home/ark/${CHIPSET}_core_builds/fake-08sa rev-parse HEAD > Arkbuild_package_cache/${CHIPSET}/fake08.commit
fi

call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/opt/fake08/fake08
sudo cp pico8/pico8.sh Arkbuild/usr/local/bin/pico8.sh
sudo cp pico8/fake08.gptk Arkbuild/opt/fake08/
sudo chmod 777 Arkbuild/usr/local/bin/pico8.sh
