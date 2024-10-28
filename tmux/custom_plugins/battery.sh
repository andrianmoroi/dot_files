#!/usr/bin/env bash

capacity=$(cat /sys/class/power_supply/BAT1/capacity)
status=$(cat /sys/class/power_supply/BAT1/status)

normal_icons=("󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
charge_icons=("󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")

icons=("${normal_icons[@]}")

case $status in
    discharging|Discharging)
        icons=("${normal_icons[@]}")
      ;;
    high|Full)
        icons=("${charge_icons[@]}")
      ;;
    charging|Charging)
        icons=("${charge_icons[@]}")
      ;;
    *)
        icons=("${normal_icons[@]}")
      ;;
esac

index=$(((capacity+5)/10))

echo ${icons[index]}
