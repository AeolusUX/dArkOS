SHELL := /bin/bash

all: rgb10

rgb10:
	./build_rgb10.sh

clean:
	[ -d "mnt/boot" ] && sudo umount mnt/boot && sudo rm -rf mnt/boot || true
	[ -d "mnt/roms" ] && sudo umount mnt/roms && sudo rm -rf mnt/roms || true
	source utils.sh && remove_arkbuild && remove_arkbuild32
	sudo rm -rf Arkbuild Arkbuild32 mnt odroidgoA-4.4.y ArkOS_* wget-*
	@echo "Done!"

clean_complete: clean
	[ -d "${PWD}/Arkbuild_ccache" ] && sudo umount ${PWD}/Arkbuild_ccache || true
	[ -d "${PWD}/Arkbuild_ccache" ] && sudo rm -rf Arkbuild_ccache || true
	sudo rm -f build.log*
