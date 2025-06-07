##!/bin/bash

all_device_paths=$(upower -e)

items=""
for device_path in $all_device_paths; do
  device_info=$(upower -i "$device_path")

  model_line=$(echo "$device_info" | grep -E '^\s*model:\s*')
  model=""
  if [[ -n "$model_line" ]]; then
    model=$(echo "$model_line" | awk -F': ' '{st = index($0,": "); $0 = substr($0,st+2); print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
  fi

  percentage_line=$(echo "$device_info" | grep -E '^\s*percentage:\s*')
  percent_int=""
  if [[ -n "$percentage_line" ]]; then
    percentage_str=$(echo "$percentage_line" | awk -F': ' '{st = index($0,": "); $0 = substr($0,st+2); print $0}' | sed 's/^[ \t]*//;s/[ \t]*$//')
    percent_int=$(echo "$percentage_str" | tr -cd '0-9')
  fi

if [[ -n "$model" && -n "$percent_int" ]]; then
  icon="🔋"  # Default icon
  color="white"  # Default color
  if (( percent_int >= 70 )); then
    icon="🔋"
    color="green"
  elif (( percent_int >= 21 )); then
    icon=""
    color="yellow"
  else
    icon=""
    color="orange"
  fi

  items+="<span foreground=\"$color\"><b>$icon  $model: $percent_int%</b></span>\n"
fi
done

if [[ -z "$items" ]]; then
  echo "No battery devices found." | rofi -dmenu -i -p "Battery Status"
  exit 0
fi

echo -e "$items" | rofi -markup-rows -dmenu -i -p "Battery Status"

exit 0
