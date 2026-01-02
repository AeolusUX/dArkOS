#!/bin/bash

DEVICE=""
CONFIG=""

if [ -f "/boot/rk3326-rg351v-linux.dtb" ]; then
  DEVICE="RG351V"
  CONFIG="lzdoom.ini.351v"
elif [ -f "/boot/rk3326-rg351mp-linux.dtb" ] || [ -f "/boot/rk3326-g350-linux.dtb" ] || [ -f "/boot/rk3326-r36s-linux.dtb" ]; then
  DEVICE="RG351MP"
  CONFIG="lzdoom.ini.351mp"
elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
  DEVICE="Gameforce Chi"
  CONFIG="lzdoom.ini.chi"
elif [ -f "/boot/rk3326-odroidgo2-linux.dtb" ] || [ -f "/boot/rk3326-odroidgo2-linux-v11.dtb" ]; then
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
    DEVICE="RGB10/OGA 1.1 (BE)"
    CONFIG="lzdoom.ini.rgb10"
  else
    DEVICE="RK2020/OGA 1.0"
    CONFIG="lzdoom.ini.rk2020"
  fi
elif [ -f "/boot/rk3326-odroidgo3-linux.dtb" ]; then
  if [ "$(cat ~/.config/.OS)" == "ArkOS" ] && [ "$(cat ~/.config/.DEVICE)" == "RGB10MAX" ]; then
    DEVICE="RGB10MAX"
  else
    DEVICE="Maybe an OGS"
  fi
  CONFIG="lzdoom.ini.rgb10max"
elif [ -f "/boot/rk3566.dtb" ] || [ -f "/boot/rk3566-OC.dtb" ]; then
  if [ "$(cat ~/.config/.DEVICE)" == "RG353M" ]; then
    DEVICE="RG353M"
    CONFIG="lzdoom.ini.353m"
  elif [ "$(cat ~/.config/.DEVICE)" == "RG353V" ]; then
    DEVICE="RG353V/VS"
    CONFIG="lzdoom.ini.353v"
  elif [ "$(cat ~/.config/.DEVICE)" == "RGB30" ]; then
    DEVICE="RGB30"
    CONFIG="lzdoom.ini.rk2023"
  elif [ "$(cat ~/.config/.DEVICE)" == "RK2023" ]; then
    DEVICE="RK2023"
    CONFIG="lzdoom.ini.rk2023"
  else
    DEVICE="RG503"
    CONFIG="lzdoom.ini.503"
  fi
fi

. /usr/local/bin/buttonmon.sh

if compgen -G "/boot/rk3566*" > /dev/null; then
  if test ! -z "$(cat /home/ark/.config/.DEVICE | grep RGB20PRO | tr -d '\0')"
  then
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold32x16.psf.gz
  else
    sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz
  fi
  height="20"
  width="60"
fi

printf "\nAre you sure you want to default your LZdoom settings?\n"
printf "\nPress A to continue.  Press B to exit.\n"
while true
do
    Test_Button_A
    if [ "$?" -eq "10" ]; then
      cp -f /home/ark/.config/lzdoom/backup/${CONFIG} /home/ark/.config/lzdoom/lzdoom.ini
      if [ $? == 0 ]; then
        printf "\nRestored the default LZdoom settings for the\n"
        printf "$DEVICE"
        sleep 5
      else
        printf "\nFailed to restore the LZdoom settings for $DEVICE"
        sleep 5
      fi
      exit 0
	fi

    Test_Button_B
    if [ "$?" -eq "10" ]; then
	  printf "\nExiting without defaulting the LZdoom settings."
	  sleep 1
      exit 0
	fi
done
