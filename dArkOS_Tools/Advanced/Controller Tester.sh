#!/bin/bash

clear

if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  sudo setfont /usr/share/consolefonts/Lat7-TerminusBold28x14.psf.gz
else
  sudo setfont /usr/share/consolefonts/Lat7-Terminus16.psf.gz
fi
sudo chmod 666 /dev/tty1
export DIALOGRC=/opt/inttools/noshadows.dialogrc
printf "\033c" > /dev/tty1

if [[ -z $(pgrep -f gptokeyb) ]] && [[ -z $(pgrep -f oga_controls) ]]; then
  sudo chmod 666 /dev/uinput
  export SDL_GAMECONTROLLERCONFIG_FILE="/opt/inttools/gamecontrollerdb.txt"
  if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]] || [[ -e "/dev/input/by-path/platform-gameforce-gamepad-event-joystick" ]]; then
    export HOTKEY="l3"
  fi
  /opt/inttools/gptokeyb -1 "controllerTester" -c "/opt/inttools/keys.gptk" > /dev/null &
  disown
  set_gptokeyb="Y"
fi

hotkey="Select"
if [[ ! -z $(cat /etc/emulationstation/es_input.cfg | grep "190000004b4800000010000001010000") ]]; then
  hotkey="Minus"
elif [ -f "/boot/rk3326-gameforce-linux.dtb" ]; then
  hotkey="1"
fi

echo "The purpose of this tool to test the device"
echo "controls"
sleep 2
echo ""
echo "Press ${hotkey} and Start buttons at anytime to"
echo "exit this program."
echo ""

/usr/local/bin/controllerTester

if [[ ! -z "$set_gptokeyb" ]]; then
  pgrep -f gptokeyb | sudo xargs kill -9
  unset SDL_GAMECONTROLLERCONFIG_FILE
fi

if [[ ! -e "/dev/input/by-path/platform-odroidgo2-joypad-event-joystick" ]]; then
  sudo setfont /usr/share/consolefonts/Lat7-Terminus20x10.psf.gz
fi

export DIALOGRC=
printf "\033c" > /dev/tty1