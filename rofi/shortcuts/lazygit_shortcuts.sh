#!/bin/bash

GITHUBLOCATION=~/GitHub/

mapfile -t PROJECTS < <(find "$GITHUBLOCATION" -type d -name ".git" -prune -exec dirname {} \;)

CHOICE=$(printf "%s\n" "${PROJECTS[@]}" | sed "s|$GITHUBLOCATION||" | rofi -dmenu -i -p "Lazygit")



if [ -n "$CHOICE" ]; then
    # Switch to workspace 4 depending on the WM
    if pgrep -x Hyprland >/dev/null 2>&1; then
        hyprctl --batch "dispatch workspace 4; dispatch exec kitty -e lazygit -p '${GITHUBLOCATION}${CHOICE}'"
    elif pgrep -x i3 >/dev/null 2>&1; then
        kitty -e lazygit -p "${GITHUBLOCATION}${CHOICE}" &
    fi

    # Launch lazygit
fi
