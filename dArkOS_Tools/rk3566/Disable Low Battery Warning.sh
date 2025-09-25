#!/bin/bash
printf "\033c" >> /dev/tty1
sudo systemctl disable batt_led
sudo systemctl stop batt_led
printf "\n\n\n\e[32mLow battery warning has been disabled.\n"
sudo cp /usr/local/bin/Enable\ Low\ Battery\ Warning.sh /opt/system/Advanced/.
sudo rm /opt/system/Advanced/Disable\ Low\ Battery\ Warning.sh
sleep 2
printf "\033c" >> /dev/tty1
sudo systemctl restart emulationstation

