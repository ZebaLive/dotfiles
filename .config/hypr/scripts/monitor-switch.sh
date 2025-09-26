#!/bin/bash

# Simple USB monitor orientation toggle script
# One keybinding to auto-detect and toggle orientation

LAPTOP_MONITOR="eDP-1"
USB_MONITOR="DP-3"
CONFIG_FILE="$HOME/.config/hypr/usb_monitor_orientation"

# Default to vertical if no config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "vertical" > "$CONFIG_FILE"
fi

# Check if USB monitor is connected
if ! hyprctl monitors -j | jq -r '.[].name' | grep -q "^${USB_MONITOR}$"; then
    echo "USB monitor not connected"
    exit 0
fi

# Toggle orientation
CURRENT_ORIENTATION=$(cat "$CONFIG_FILE")
if [ "$CURRENT_ORIENTATION" = "vertical" ]; then
    NEW_ORIENTATION="horizontal"
    TRANSFORM="0"
else
    NEW_ORIENTATION="vertical"
    TRANSFORM="3"
fi

# Save new orientation
echo "$NEW_ORIENTATION" > "$CONFIG_FILE"

# Apply monitor configuration
echo "Setting USB monitor to $NEW_ORIENTATION orientation"
hyprctl keyword monitor "$LAPTOP_MONITOR,2880x1920@120,-2880x0,2"
hyprctl keyword monitor "$USB_MONITOR,1920x1080@60,0x0,1,transform,$TRANSFORM"

# Set wallpaper if script exists
if [ -x ~/.config/hypr/scripts/wallpaper.sh ]; then
    ~/.config/hypr/scripts/wallpaper.sh
fi