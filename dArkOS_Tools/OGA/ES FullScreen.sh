#!/bin/bash

sudo cp -f /usr/bin/emulationstation/emulationstation.fullscreen /usr/bin/emulationstation/emulationstation
sudo printf "\033c" >> /dev/tty1
sudo systemctl restart emulationstation
