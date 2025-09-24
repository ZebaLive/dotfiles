#!/bin/bash

# Script to handle automatic monitor switching
# When DP-4 (external monitor) is connected, disable laptop monitor
# When DP-4 is disconnected, enable laptop monitor

# Get list of connected monitors
CONNECTED_MONITORS=$(hyprctl monitors -j | jq -r '.[].name')

# Check if external monitor DP-4 is connected
if echo "$CONNECTED_MONITORS" | grep -q "DP-4"; then
    echo "External monitor DP-4 detected. Disabling laptop monitor eDP-1."
    # Configure external monitor as primary and disable laptop monitor
    hyprctl keyword monitor "DP-4,2560x1440@144,0x0,1"
    hyprctl keyword monitor "eDP-1,disable"
else
    echo "External monitor DP-4 not detected. Enabling laptop monitor eDP-1."
    # Enable laptop monitor when external monitor is not present
    hyprctl keyword monitor "eDP-1,2880x1920@120,0x0,2"
fi