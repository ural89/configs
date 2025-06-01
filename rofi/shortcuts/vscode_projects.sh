#!/bin/bash

PROJECT_ROOT="~/GitHub"
CODE_CMD="code" # or full path to code if needed

# Find all folders that contain a `.git` directory
mapfile -t PROJECT_PATHS < <(find "$PROJECT_ROOT" -type d -name ".git" -prune -exec dirname {} \;)

# Create a name-to-path map
CHOICE=$(printf "%s\n" "${PROJECT_PATHS[@]}" | sed "s|$PROJECT_ROOT/||" | rofi -dmenu -i -p "Open VS Code Project")

# If a project was selected
if [ -n "$CHOICE" ]; then
    FULL_PATH="$PROJECT_ROOT/$CHOICE"
    "$CODE_CMD" "$FULL_PATH"
fi

