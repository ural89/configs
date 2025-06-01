##!/bin/bash

# Get all UPower device paths
all_device_paths=$(upower -e)

# Build Rofi input list
items=""
for device_path in $all_device_paths; do
  # Get detailed information for the current device
  device_info=$(upower -i "$device_path")

  # Extract model, checking if the 'model' line exists and has a value
  model_line=$(echo "$device_info" | grep -E '^\s*model:\s*')
  model=""
  if [[ -n "$model_line" ]]; then
    # Extract the value after ': ' and trim whitespace
    model=$(echo "$model_line" | awk -F': ' '{st = index($0,": "); $0 = substr($0,st+2); print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
  fi

  # Extract percentage, checking if the 'percentage' line exists and has a value
  percentage_line=$(echo "$device_info" | grep -E '^\s*percentage:\s*')
  percent_int=""
  if [[ -n "$percentage_line" ]]; then
    percentage_str=$(echo "$percentage_line" | awk -F': ' '{st = index($0,": "); $0 = substr($0,st+2); print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
    # Extract only digits from the percentage string
    percent_int=$(echo "$percentage_str" | tr -cd '0-9')
  fi

  # Only add to Rofi list if both model and percentage were successfully extracted and are not empty
  if [[ -n "$model" && -n "$percent_int" ]]; then
    icon="🔋" # Default icon
    # Use your existing icon logic
    if (( percent_int >= 90 )); then
      icon="🔋"  # Full battery
    elif (( percent_int >= 20 )); then
      icon=""  # Half battery (or your preferred icon for partial)
    else
      icon="⚠️"  # Low battery warning
    fi
    items+="$icon $model: $percent_int%\n"
  fi
done

# If no suitable battery devices were found, display a message
if [[ -z "$items" ]]; then
  echo "No battery devices found." | rofi -dmenu -i -p "Battery Status"
  exit 0
fi

# Display Rofi menu
# The -e for echo interprets the \n correctly for Rofi
echo -e "$items" | rofi -dmenu -i -p "Battery Status"

exit 0
