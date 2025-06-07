#!/bin/bash

CHOICE=$(echo -e \
"  Run\n\
  TODO\n\
💼 Work Setup\n\
  Unity Projects\n\
  Power Menu\n\
🧰 Lazygit Shortcuts\n\
  Translate\n\
🔋 Battery Status\n\
  Timer\n\
  Wifi\n\
  Kill\n\
🎧 Headphone Call\n\
🎧 Headphone Lowcall\n\
🎧 Headphone Highfidelity\n\
🔗 Mount GDrive\n\
   VS Code Projects\n\
  Exit" | rofi -dmenu -i -p "Shortcuts")

case "$CHOICE" in
  "🔗 Mount GDrive")
    mkdir -p ~/mnt/gdrive
    rclone mount gdrive: ~/mnt/gdrive &
    ;;
    "  Run")
        rofi -show run
    ;;
    "  TODO")
        rofi -show todo -modi todo:~/.config/rofi/plugins/rofi-todo.sh
    ;;
  "💼 Work Setup")
if [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ] || pgrep -x hyprland >/dev/null; then
    echo "Setting up work environment in Hyprland..."

    hyprctl --batch "
        dispatch workspace 3;
        dispatch exec kitty -e ncspot;
        dispatch exec kitty -e peaclock;
        dispatch exec discord;
        dispatch exec bash -c 'sleep 6 && worksetuplayout.sh';
    "

elif [ "$XDG_CURRENT_DESKTOP" == "i3" ] || pgrep -x i3 >/dev/null; then
    echo "Setting up work environment in i3..."

    # Switch to workspace 3
    i3-msg workspace "3"

    # Launch the applications
    kitty -e ncspot &
    kitty -e peaclock &
    discord &

    # Run layout setup after delay
    (sleep 6 && worksetuplayout.sh) &

else
    echo "Unsupported or unknown window manager."
fi
    ;;
"  Wifi")
    ~/.config/rofi/plugins/wifimenu.sh
    ;;
  "🧰 Lazygit Shortcuts")
    ~/.config/rofi/shortcuts/lazygit_shortcuts.sh
    ;;
"  Unity Projects")
    ~/.config/rofi/shortcuts/unity_shortcuts.sh
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
  "  Kill")
    ~/.config/rofi/plugins/rofikill.sh
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

