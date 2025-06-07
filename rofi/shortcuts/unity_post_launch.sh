
#!/bin/bash

PROJECT_NAME="$1"
VERSION="$2"
PROJECT_PATH="$3"

# Example actions
echo "$(date): Launched $PROJECT_NAME (v$VERSION) at $PROJECT_PATH" >> ~/unity_launch_log.txt

    
notify-send "Unity Launch" "$PROJECT_NAME (v$VERSION)"


hyprctl dispatch focuswindow "title:peaclock"
sleep 0.3

# Simulate a press and release of 'r' and 'space'
ydotool key 19:1 19:0
sleep 0.3
ydotool key 57:1 57:0



exit 0
