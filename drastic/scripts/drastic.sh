#!/bin/bash

directory="$(dirname "$1" | cut -d "/" -f2)"

if  [[ ! -d "/${directory}/nds/backup" ]]; then
  mkdir /${directory}/nds/backup
fi
if  [[ ! -d "/${directory}/nds/cheats" ]]; then
  mkdir /${directory}/nds/cheats
fi
if  [[ ! -d "/${directory}/nds/savestates" ]]; then
  mkdir /${directory}/nds/savestates
fi
if  [[ ! -d "/${directory}/nds/slot2" ]]; then
  mkdir /${directory}/nds/slot2
fi


if [[ -d "/opt/drastic/backup" && ! -L "/opt/drastic/backup" ]]; then
  cp -n /opt/drastic/backup/* /${directory}/nds/backup/
  rm -rf /opt/drastic/backup/
fi

if [[ -d "/opt/drastic/savestates" && ! -L "/opt/drastic/backup" ]]; then
  cp -n /opt/drastic/savestates/* /${directory}/nds/savestates/
  rm -rf /opt/drastic/savestates/
fi

rm -rf /opt/drastic/cheats
rm -rf /opt/drastic/slot2

ln -sf /${directory}/nds/backup /opt/drastic/
ln -sf /${directory}/nds/cheats /opt/drastic/
ln -sf /${directory}/nds/savestates /opt/drastic/
ln -sf /${directory}/nds/slot2 /opt/drastic/

echo "VAR=drastic" > /home/ark/.config/KILLIT
sudo systemctl restart killer_daemon.service

cd /opt/drastic
./drastic "$1"

sudo systemctl stop killer_daemon.service

sudo systemctl restart ogage &
