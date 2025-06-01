#!/bin/bash

GITHUBLOCATION=~/GitHub

LAZYGIT="lazygit"

mapfile -t PROJECTS < <(find "$GITHUBLOCATION" -type d -name ".git" -prune -exec dirname {} \;)

CHOICE=$(printf "%s\n" "${PROJECTS[@]}"  | sed "s|$GITHUBLOCATION/||"| rofi -dmenu -i -p "Lazgit")

if [ -n "$CHOICE" ]; then
    kitty -e "$LAZYGIT" -p  "$GITHUBLOCATION/""$CHOICE"
fi
