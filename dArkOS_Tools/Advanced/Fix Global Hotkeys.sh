#!/bin/bash

. /usr/local/bin/buttonmon.sh

echo "Are you sure you want to restart Global Hotkeys?"
echo "Press A to continue.  Press B to exit."
while true
do
    Test_Button_A
    if [ "$?" -eq "10" ]; then
      echo "Stopping Global hotkey service..."
      sudo systemctl stop ogage
      sudo systemctl disable ogage
      sleep 1
      echo "Restoring a backup of the Global hotkey service..."
      sudo cp -f -v /etc/systemd/system/ogage.service.bak /etc/systemd/system/ogage.service
      sleep 1
      echo "Starting Global hotkey service..."
      sudo systemctl daemon-reload
      sudo systemctl start ogage
      sleep 1
      echo "Making sure Global hotkey service (oga_service) is enabled so it autostarts during boot as it's supposed to..."
      sudo systemctl enable ogage
      echo "Done."
      sleep 2
      printf "\033[0m"
      exit 0
    fi

    Test_Button_B
    if [ "$?" -eq "10" ]; then
      echo "Exiting without restarting Global Hotkeys"
	  sleep 1
	  exit 0
	fi
done

