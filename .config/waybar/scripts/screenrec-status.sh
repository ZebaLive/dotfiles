#!/bin/bash

STATUSFILE="/tmp/wl-screenrec-status.json"

# Function to format time duration
format_duration() {
    local start_time="$1"
    local current_time=$(date +%s)
    local duration=$((current_time - start_time))
    
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    local seconds=$((duration % 60))
    
    if [ $hours -gt 0 ]; then
        printf "%02d:%02d:%02d" $hours $minutes $seconds
    else
        printf "%02d:%02d" $minutes $seconds
    fi
}

# Check if status file exists
if [ ! -f "$STATUSFILE" ]; then
    echo '{"text": "", "class": "not-recording"}'
    exit 0
fi

# Read status
recording=$(jq -r '.recording' "$STATUSFILE" 2>/dev/null)
start_time=$(jq -r '.start_time' "$STATUSFILE" 2>/dev/null)
mode=$(jq -r '.mode' "$STATUSFILE" 2>/dev/null)

if [ "$recording" = "true" ] && [ "$start_time" != "null" ]; then
    duration=$(format_duration "$start_time")
    case "$mode" in
        "fullscreen")
            icon="🔴"
            tooltip="Recording fullscreen ($duration)"
            ;;
        "region")
            icon="🟠"
            tooltip="Recording region ($duration)"
            ;;
        "window")
            icon="🟡"
            tooltip="Recording window ($duration)"
            ;;
        *)
            icon="🔴"
            tooltip="Recording ($duration)"
            ;;
    esac
    
    echo "{\"text\": \"$icon $duration\", \"class\": \"recording\", \"tooltip\": \"$tooltip\"}"
else
    echo '{"text": "", "class": "not-recording"}'
fi
