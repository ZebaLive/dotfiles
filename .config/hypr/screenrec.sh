#!/bin/bash

# Screen recording script using wl-screenrec
# Usage: screenrec.sh [fullscreen|region|window|stop]

RECORDINGS_DIR="$HOME/Videos/Recordings"
PIDFILE="/tmp/wl-screenrec.pid"
STATUSFILE="/tmp/wl-screenrec-status.json"

# Create recordings directory if it doesn't exist
mkdir -p "$RECORDINGS_DIR"

# Function to update status file
update_status() {
    local recording="$1"
    local start_time="$2"
    local mode="$3"
    
    if [ "$recording" = "true" ]; then
        cat > "$STATUSFILE" << EOF
{
  "recording": true,
  "start_time": $start_time,
  "mode": "$mode"
}
EOF
    else
        cat > "$STATUSFILE" << EOF
{
  "recording": false
}
EOF
    fi
}

# Function to check if recording is active
is_recording() {
    # Prefer checking for any running wl-screenrec processes for the current user.
    # This handles cases where wl-screenrec forks/execs and the background PID we
    # wrote to the PIDFILE may not be the long-lived process.
    if command -v pgrep >/dev/null 2>&1; then
        PIDS=$(pgrep -u "$(id -u)" -f "wl-screenrec" || true)
    else
        # Fallback if pgrep is not available
        PIDS=$(ps -u "$(id -u)" -o pid= -o comm= | awk '/wl-screenrec/ {print $1}' || true)
    fi

    if [ -n "$PIDS" ]; then
        # store the first running pid as canonical
        PID=$(echo "$PIDS" | head -n1)
        echo "$PID" > "$PIDFILE"
        return 0
    fi

    # Fallback to checking PIDFILE if present
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PIDFILE"
            update_status "false"
        fi
    fi

    return 1
}

# Function to stop recording
stop_recording() {
    # Try to find any running wl-screenrec processes and kill them.
    if command -v pgrep >/dev/null 2>&1; then
        PIDS=$(pgrep -u "$(id -u)" -f "wl-screenrec" || true)
    else
        PIDS=$(ps -u "$(id -u)" -o pid= -o comm= | awk '/wl-screenrec/ {print $1}' || true)
    fi

    if [ -n "$PIDS" ]; then
        # Kill all matching pids
        kill $PIDS 2>/dev/null || true
        for pid in $PIDS; do
            wait "$pid" 2>/dev/null || true
        done
        rm -f "$PIDFILE"
        update_status "false"
        notify-send "Screen Recording" "Recording stopped and saved to $RECORDINGS_DIR" -i video-x-generic
        return 0
    fi

    # Fallback: try PIDFILE (if process didn't show up via pgrep)
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            kill "$PID" 2>/dev/null
            wait "$PID" 2>/dev/null
            rm -f "$PIDFILE"
            update_status "false"
            notify-send "Screen Recording" "Recording stopped and saved to $RECORDINGS_DIR" -i video-x-generic
            return 0
        else
            rm -f "$PIDFILE"
            update_status "false"
        fi
    fi

    return 1
}

# Function to start recording
start_recording() {
    local mode="$1"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local start_time=$(date +%s)
    local filename="$RECORDINGS_DIR/recording_${timestamp}.mp4"
    
    # Check if already recording
    if is_recording; then
        notify-send "Screen Recording" "Recording is already active! Press F11 to stop." -i dialog-warning
        return 1
    fi
    
    case "$mode" in
        "fullscreen")
            notify-send "Screen Recording" "Starting fullscreen recording..." -i video-x-generic
            # Get the primary monitor for fullscreen recording
            local primary_output=$(hyprctl monitors -j | jq -r '.[0].name')
            "$WL_SCREENREC" --output "$primary_output" -f "$filename" &
            local recording_pid=$!
            ;;
        "region")
            notify-send "Screen Recording" "Select region to record..." -i video-x-generic
            "$WL_SCREENREC" -g "$(slurp)" -f "$filename" &
            local recording_pid=$!
            ;;
        "window")
            notify-send "Screen Recording" "Click on window to record..." -i video-x-generic
            # Get window geometry using hyprctl and slurp for window selection
            local window_info=$(hyprctl -j clients | jq -r '.[] | select(.focusHistoryID == 0) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
            if [ -z "$window_info" ]; then
                # Fallback to slurp for window selection
                "$WL_SCREENREC" -g "$(slurp)" -f "$filename" &
                local recording_pid=$!
            else
                "$WL_SCREENREC" -g "$window_info" -f "$filename" &
                local recording_pid=$!
            fi
            ;;
        *)
            echo "Usage: $0 [fullscreen|region|window|stop]"
            exit 1
            ;;
    esac
    
    # Store PID for later termination
    echo "$recording_pid" > "$PIDFILE"
    
    # Give the process a moment to start
    sleep 0.1
    
    # Verify the process actually started
    if ! ps -p "$recording_pid" > /dev/null 2>&1; then
        rm -f "$PIDFILE"
        notify-send "Error" "Failed to start recording" -i dialog-error
        exit 1
    fi
    
    # Update status file
    update_status "true" "$start_time" "$mode"
}

# Set the full path to wl-screenrec
WL_SCREENREC="$HOME/.cargo/bin/wl-screenrec"

# Check if wl-screenrec is installed
if ! [ -x "$WL_SCREENREC" ]; then
    notify-send "Error" "wl-screenrec is not found at $WL_SCREENREC. Please check installation." -i dialog-error
    exit 1
fi

# Check if slurp is installed (needed for region/window selection)
if [ "$1" = "region" ] || [ "$1" = "window" ]; then
    if ! command -v slurp &> /dev/null; then
        notify-send "Error" "slurp is not installed. Please install it for region/window recording." -i dialog-error
        exit 1
    fi
fi

# Main logic
case "$1" in
    "stop")
        if stop_recording; then
            exit 0
        else
            notify-send "Screen Recording" "No active recording to stop" -i dialog-information
            exit 1
        fi
        ;;
    "fullscreen"|"region"|"window")
        start_recording "$1"
        ;;
    *)
        echo "Usage: $0 [fullscreen|region|window|stop]"
        exit 1
        ;;
esac
