#!/bin/bash

# Copy and install drastic standalone emulator
sudo mkdir -p Arkbuild/opt/drastic
sudo mkdir -p Arkbuild/opt/drastic/config/backup
sudo mkdir -p Arkbuild/opt/drastic/input_record
sudo mkdir -p Arkbuild/opt/drastic/microphone
sudo mkdir -p Arkbuild/opt/drastic/profiles
sudo mkdir -p Arkbuild/opt/drastic/scripts
sudo mkdir -p Arkbuild/opt/drastic/system
sudo mkdir -p Arkbuild/opt/drastic/unzip_cache
sudo cp drastic/configs/drastic.cfg.${UNIT} Arkbuild/opt/drastic/config/drastic.cfg
sudo cp drastic/drastic_logo* Arkbuild/opt/drastic/.
sudo cp drastic/usrcheat.dat Arkbuild/opt/drastic/.
sudo cp drastic/game_database.xml Arkbuild/opt/drastic/.
sudo cp -R drastic/system/ Arkbuild/opt/drastic/
sudo cp -R drastic/configs/ Arkbuild/opt/drastic/config/backup/
sudo cp drastic/bin/drastic Arkbuild/opt/drastic/
sudo cp drastic/scripts/drastic.sh Arkbuild/usr/local/bin/
call_chroot "chown -R ark:ark /opt/"
sudo chmod 777 Arkbuild/usr/local/bin/drastic.sh
sudo chmod 777 Arkbuild/opt/drastic/drastic
