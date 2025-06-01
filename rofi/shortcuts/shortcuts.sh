#!/bin/bash

CHOICE=$(echo -e \
"  Run\n\
💼 Work Setup\n\
   VS Code Projects\n\
  Power Menu\n\
🧰 Lazygit\n\
  Translate\n\
🔋 Battery Status\n\
  Timer\n\
  Wifi\n\
🎧 Headphone Call\n\
🎧 Headphone Lowcall\n\
🎧 Headphone Highfidelity\n\
🔗 Mount GDrive\n\
  Exit" | rofi -dmenu -i -p "Shortcuts")

case "$CHOICE" in
  "🔗 Mount GDrive")
    mkdir -p ~/mnt/gdrive
    rclone mount gdrive: ~/mnt/gdrive &
    ;;
    "  Run")
        rofi -show run
    ;;
  "💼 Work Setup")
    hyprctl --batch "
  dispatch workspace 3;
  dispatch exec kitty -e ncspot;
  dispatch exec kitty -e peaclock;
  dispatch exec discord;
  dispatch exec bash -c 'sleep 6 && worksetuplayout.sh';
"
    ;;
"  Wifi")
    ~/.config/rofi/plugins/wifimenu.sh
    ;;
  "🧰 Lazygit")
    ~/.config/rofi/shortcuts/lazygit_shortcuts.sh
    ;;
  "   VS Code Projects")
    ~/.config/rofi/shortcuts/vscode_projects.sh
    ;;
  "🎧 Headphone Highfidelity")
   pactl set-card-profile bluez_card.80_C3_BA_73_33_73 a2dp-sink; playerctl play
    ;;
  "🔋 Battery Status")
  ~/.config/rofi/plugins/battery.sh
  ;;
  "  Timer")
  ~/.config/rofi/plugins/timer.sh
  ;;
  "  Translate")
  ~/.config/rofi/plugins/translate.sh
  ;;
  "🎧 Headphone Call")
    pactl set-card-profile bluez_card.80_C3_BA_73_33_73 headset-head-unit; playerctl pause
    ;;
  "🎧 Headphone Lowcall")
    pactl set-card-profile bluez_card.80_C3_BA_73_33_73 headset-head-unit-cvsd; playerctl pause
    ;;
  "  Power Menu")
    
    rofi -modi "powermenu:~/.config/rofi/plugins/powermenu.sh" -show powermenu
    ;;
  "  Exit")
    exit 0
    ;;
esac

