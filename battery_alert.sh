#!/bin/bash
# battery_alert script to check if battery is lower than 20% or greater than 80%
# checking intervals are each 5 mins (300 secs) 

while true
    do
        export DISPLAY=:0.0
        battery_level=`acpi -b | grep -P -o '[0-9]+(?=%)'`
        if on_ac_power; then
            if [ $battery_level -ge 80 ]; then
                notify-send "Battery charging above 60%. Please unplug your AC adapter!" "Charging: ${battery_level}% "
             fi
        else
             if [ $battery_level -le 20 ]; then
                notify-send "Battery is lower 40%. Need to charging! Please plug your AC adapter." "Charging: ${battery_level}%"
             fi
        fi
    
        sleep 300
    done