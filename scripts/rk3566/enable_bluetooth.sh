#!/bin/bash
echo 0 | sudo tee /sys/class/rfkill/rfkill0/state
sleep 1
echo 1 | sudo tee /sys/class/rfkill/rfkill0/state
sleep 1
sudo rtk_hciattach -n /dev/ttyS1 rtk_h5 115200
