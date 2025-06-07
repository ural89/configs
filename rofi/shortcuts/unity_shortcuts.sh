#!/bin/bash

UNITY_ROOT=~/Unity/Hub/Editor
SEARCH_ROOT=~/GitHub

mapfile -t PROJECTS < <(find "$SEARCH_ROOT" -type f -path '*/ProjectSettings/ProjectVersion.txt')

MENU=""
for VERSION_FILE in "${PROJECTS[@]}"; do
  PROJECT_DIR=$(dirname "$(dirname "$VERSION_FILE")")
  VERSION=$(grep -oP '(?<=m_EditorVersion: )[^ ]+' "$VERSION_FILE")
  PROJECT_NAME=$(basename "$PROJECT_DIR")
  MENU+="$PROJECT_NAME [$VERSION]\n"
done

MENU+="Exit"

CHOICE=$(echo -e "$MENU" | rofi -dmenu -i -p "Select Unity Project:")

if [[ "$CHOICE" == "Exit" || -z "$CHOICE" ]]; then
  exit 0
fi

PROJECT_NAME=$(echo "$CHOICE" | sed -E 's/ \[.*//')
VERSION=$(echo "$CHOICE" | sed -E 's/.*\[([^]]+)\]/\1/')

PROJECT_PATH=$(for P in "${PROJECTS[@]}"; do
  DIR=$(dirname "$(dirname "$P")")
  NAME=$(basename "$DIR")
  if [[ "$NAME" == "$PROJECT_NAME" ]]; then
    echo "$DIR"
    break
  fi
done)

UNITY_BIN="$UNITY_ROOT/$VERSION/Editor/Unity"
if [[ ! -x "$UNITY_BIN" ]]; then
  echo "❌ Unity version $VERSION not found in $UNITY_BIN"
  exit 1
fi

# Optional: make sure it's executable
AFTER_SCRIPT="$HOME/.config/rofi/shortcuts/unity_post_launch.sh"

if [[ -x "$AFTER_SCRIPT" ]]; then
  "$AFTER_SCRIPT" "$PROJECT_NAME" "$VERSION" "$PROJECT_PATH" &
fi
hyprctl dispatch workspace 1
"$UNITY_BIN" -projectPath "$PROJECT_PATH"
