#!/bin/bash

# Simple wallpaper script for USB monitor
# Always sets DP-3 (USB monitor) to jellyfish wallpaper

USB_MONITOR="DP-3"
WALLPAPER_PATH="$HOME/Pictures/Wallpapers/jellyfish.jpg"

# Check if the wallpaper file exists
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Warning: Wallpaper file not found: $WALLPAPER_PATH"
    exit 1
fi

# Check if USB monitor is connected
if hyprctl monitors -j | jq -r '.[].name' | grep -q "^${USB_MONITOR}$"; then
    echo "Setting wallpaper for USB monitor: $WALLPAPER_PATH"
    swww img --outputs "$USB_MONITOR" "$WALLPAPER_PATH"
else
    echo "USB monitor ($USB_MONITOR) not connected"
fi