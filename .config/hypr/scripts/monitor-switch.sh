#!/bin/bash

# Simple USB monitor orientation toggle script
# Auto-detects current orientation from monitor transform state

LAPTOP_MONITOR="eDP-1"
USB_MONITOR="DP-3"

# Check if USB monitor is connected
if ! hyprctl monitors -j | jq -r '.[].name' | grep -q "^${USB_MONITOR}$"; then
    echo "USB monitor not connected"
    exit 0
fi

# Get current transform value from the monitor itself
CURRENT_TRANSFORM=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$USB_MONITOR\") | .transform")

# Toggle orientation based on current transform
if [ "$CURRENT_TRANSFORM" = "3" ]; then
    # Currently vertical (transform 3), switch to horizontal
    NEW_ORIENTATION="horizontal"
    TRANSFORM="0"
else
    # Currently horizontal (transform 0) or any other state, switch to vertical
    NEW_ORIENTATION="vertical"
    TRANSFORM="3"
fi

# Apply monitor configuration
echo "Setting USB monitor to $NEW_ORIENTATION orientation"
hyprctl keyword monitor "$LAPTOP_MONITOR,2880x1920@120,-2880x0,2"
hyprctl keyword monitor "$USB_MONITOR,1920x1080@60,0x0,1,transform,$TRANSFORM"

# Set wallpaper after orientation change with appropriate resize mode
echo "Setting wallpaper with $RESIZE_MODE mode for $NEW_ORIENTATION orientation"
sleep 1 # Brief pause to ensure monitor is ready
swww img --outputs "$USB_MONITOR" ~/Pictures/Wallpapers/'Forest 2.png'