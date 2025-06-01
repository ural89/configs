
#!/bin/bash

# Prompt for duration
DURATION=$(rofi -dmenu -p "Set Timer (e.g. 5m, 30s, 1h):")
[[ -z "$DURATION" ]] && exit 0

# Convert input to seconds using `timeout` format
TIMEOUT_DURATION="$DURATION"

# Optional: Ask for a label
LABEL=$(rofi -dmenu -p "Label (optional):")
[[ -z "$LABEL" ]] && LABEL="Timer"

# Wait
sleep "$TIMEOUT_DURATION"

# Notify and play sound
notify-send "⏰ Timer Done" "$LABEL ($DURATION)"
paplay /usr/share/sounds/freedesktop/stereo/complete.oga 2>/dev/null &
