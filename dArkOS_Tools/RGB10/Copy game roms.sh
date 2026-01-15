#!/bin/bash
USB_MOUNT="/mnt/usbdrive"
ROMS_DIR="/roms"
USER_ID=1002
GROUP_ID=1002

# Script by fwy13.

echo "Scanning USB drive for ROM folders..."

if ! mountpoint -q "$USB_MOUNT"; then
  echo "USB drive is not mounted at $USB_MOUNT"
  exit 1
fi

for system_dir in "$USB_MOUNT"/*; do
  [ -d "$system_dir" ] || continue

  system_name=$(basename "$system_dir")
  target_dir="$ROMS_DIR/$system_name"

  if [ ! -d "$target_dir" ]; then
    echo "Skipping unknown system: $system_name"
    continue
  fi

  echo "Processing system: $system_name"

  find "$system_dir" -maxdepth 1 -type f | while read -r rom; do
    rom_name=$(basename "$rom")

    if [ ! -f "$target_dir/$rom_name" ]; then
      echo "  Copying: $rom_name"
      cp "$rom" "$target_dir/"
    else
      echo "  Exists, skipping: $rom_name"
    fi
  done
done

chown -R $USER_ID:$GROUP_ID "$ROMS_DIR"

echo "ROM copy completed."
sleep 2