#!/bin/bash

CHOICE=$(echo -e \
"🔗 Mount GDrive\n\
💼 Work Setup\n\
🎧 Headphone Call\n\
🎧 Headphone Lowcall\n\
🎧 Headphone Highfidelity\n\
⏳ Start Timer\n\
🛑 Exit" | rofi -dmenu -i -p "General Shortcuts")

case "$CHOICE" in
  "🔗 Mount GDrive")
    mkdir -p ~/mnt/gdrive
    rclone mount gdrive: ~/mnt/gdrive &
    ;;
  "💼 Work Setup")
    hyprctl dispatch workspace 3
    kitty -e ncspot &
    kitty -e peaclock &
    discord &
    bash -c 'worksetup.sh'&
    ;;
  "🎧 Headphone Highfidelity")
   pactl set-card-profile bluez_card.80_C3_BA_73_33_73 a2dp-sink; playerctl play
    ;;
  "🎧 Headphone Call")
    pactl set-card-profile bluez_card.80_C3_BA_73_33_73 headset-head-unit; playerctl pause
    ;;
 "⏳ Start Timer")
  ~/.config/rofi/shortcuts/timer.sh &
  ;;
  "🎧 Headphone Lowcall")
    pactl set-card-profile bluez_card.80_C3_BA_73_33_73 headset-head-unit-cvsd; playerctl pause
    ;;
  "🛑 Exit")
    exit 0
    ;;
esac

