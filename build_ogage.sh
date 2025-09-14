#!/bin/bash

# Build and install ogage (Global Hotkey Daemon)
if [ "$UNIT" == "chi" ]; then
  branch="gameforce-chi"
elif [ "$UNIT" == "g350" ]; then
  branch="g350"
elif [ "$UNIT" == "rgb10" ]; then
  branch="master"
elif [ "$UNIT" == "rk2020" ]; then
  branch="rk2020"
elif [ "$UNIT" == "rg351mp" ]; then
  branch="rg351mp"
elif [ "$UNIT" == "rg351v" ]; then
  branch="rg351v"
elif [[ "$UNIT" == *"353"* ]]; then
  branch="rg353v"
elif [[ "$UNIT" == "503" ]]; then
  branch="rg503"
elif [ "$UNIT" == "rk2023" ] || [ "$UNIT" == "rgb30" ]; then
  branch="rk2023"
fi
call_chroot "cd /home/ark &&
  git clone https://github.com/christianhaitian/ogage.git -b ${branch} &&
  cd ogage &&
  export CARGO_NET_GIT_FETCH_WITH_CLI=true &&
  cargo build --release &&
  strip target/release/ogage &&
  cp target/release/ogage /usr/local/bin/ &&
  chmod 777 /usr/local/bin/ogage
  "
sudo rm -rf Arkbuild/home/ark/ogage
sudo cp scripts/ogage.service Arkbuild/etc/systemd/system/ogage.service
call_chroot "systemctl enable ogage"
