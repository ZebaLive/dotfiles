#!/usr/bin/env bash
# amd-wl-screenrec.sh — Screen recording script using wl-screenrec (AMD‑friendly)
# Usage: screenrec.sh [fullscreen|region|window|stop] [options]
# Options:
#   -o|--output FILE   Output filename (default: record-YYYYmmdd-HHMMSS.mp4)
#   -f|--fps N         Framerate (default: 60)
#   -b|--bitrate RATE  Video bitrate (default: 8M)
#   -t|--time SEC      Limit recording time (optional)
#   --hevc             Use HEVC VA-API (instead of H.264)
#   --cpu              Force CPU encoding (libx264)

RECORDINGS_DIR="$HOME/Videos/Recordings"
PIDFILE="/tmp/wl-screenrec.pid"
STATUSFILE="/tmp/wl-screenrec-status.json"

mkdir -p "$RECORDINGS_DIR"

update_status() {
    local recording="$1"
    local start_time="${2:-0}"
    local mode="${3:-}"
    if [ "$recording" = "true" ]; then
        cat > "$STATUSFILE" << EOF
{
  "recording": true,
  "start_time": $start_time,
  "mode": "$mode"
}
EOF
    else
        echo '{"recording": false}' > "$STATUSFILE"
    fi
}

is_recording() {
    if command -v pgrep >/dev/null 2>&1; then
        PIDS=$(pgrep -u "$(id -u)" -f "wl-screenrec" || true)
    else
        PIDS=$(ps -u "$(id -u)" -o pid= -o comm= | awk '/wl-screenrec/ {print $1}' || true)
    fi
    if [ -n "$PIDS" ]; then
        PID=$(echo "$PIDS" | head -n1)
        echo "$PID" > "$PIDFILE"
        return 0
    fi
    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        if ps -p "$PID" >/dev/null 2>&1; then
            return 0
        else
            rm -f "$PIDFILE"
            update_status "false"
        fi
    fi
    return 1
}

stop_recording() {
    if command -v pgrep >/dev/null 2>&1; then
        PIDS=$(pgrep -u "$(id -u)" -f "wl-screenrec" || true)
    else
        PIDS=$(ps -u "$(id -u)" -o pid= -o comm= | awk '/wl-screenrec/ {print $1}' || true)
    fi

    if [ -n "$PIDS" ]; then
        kill $PIDS 2>/dev/null || true
        for pid in $PIDS; do
            wait "$pid" 2>/dev/null || true
        done
        rm -f "$PIDFILE"
        update_status "false"
        notify-send "Screen Recording" "Recording stopped and saved to $RECORDINGS_DIR" -i video-x-generic
        return 0
    fi

    if [ -f "$PIDFILE" ]; then
        PID=$(cat "$PIDFILE")
        if ps -p "$PID" >/dev/null 2>&1; then
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

pick_render_node() {
  for n in /dev/dri/renderD1*; do
    [[ -e "$n" ]] && { echo "$n"; return 0; }
  done
  return 1
}

WL_SCREENREC="$HOME/.cargo/bin/wl-screenrec"

if ! [ -x "$WL_SCREENREC" ]; then
    notify-send "Error" "wl-screenrec not found at $WL_SCREENREC. Please install it." -i dialog-error
    exit 1
fi

FPS=60
BITRATE="8M"
DURATION=""
OUTPUT="$RECORDINGS_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"
PREFER_HEVC=0
FORCE_CPU=0
EXTRA_WL_SR_OPTS=()

while (( "$#" )); do
  case "$1" in
    -o|--output) OUTPUT=${2:-}; shift 2 ;;
    -f|--fps)    FPS=${2:-};     shift 2 ;;
    -b|--bitrate) BITRATE=${2:-}; shift 2 ;;
    -t|--time)   DURATION=${2:-}; shift 2 ;;
    --hevc)      PREFER_HEVC=1; shift ;;
    --cpu)       FORCE_CPU=1; shift ;;
    stop)        ACTION="stop"; shift ;;
    fullscreen|region|window) ACTION="$1"; shift ;;
    *) EXTRA_WL_SR_OPTS+=("$1"); shift ;;
  esac
done

RENDER_NODE=$(pick_render_node || true)
if [[ -z "${RENDER_NODE:-}" ]]; then
  notify-send "Error" "No /dev/dri/renderD* device found (is amdgpu driver loaded?)." -i dialog-error
  exit 1
fi
if [[ ! -r "$RENDER_NODE" ]]; then
  notify-send "Error" "Cannot access $RENDER_NODE. Add your user to 'render' group (sudo usermod -aG render $USER)." -i dialog-error
  exit 1
fi

hypr_warn_transform() {
  if command -v hyprctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    local rotated
    rotated=$(hyprctl -j monitors | jq -r '.[] | select(.transform != 0) | .name' || true)
    if [[ -n "${rotated:-}" ]]; then
      notify-send "ScreenRec Warning" "Rotated outputs detected: $rotated. VA-API may fail." -i dialog-warning
    fi
  fi
}
hypr_warn_transform || true

case "${ACTION:-}" in
  stop)
    if stop_recording; then exit 0; else exit 1; fi
    ;;

  fullscreen|region|window)
    local_mode="$ACTION"
    timestamp=$(date +%Y%m%d_%H%M%S)
    start_time=$(date +%s)
    [[ "$OUTPUT" == */* ]] || OUTPUT="$RECORDINGS_DIR/$OUTPUT"

    if is_recording; then
      notify-send "Screen Recording" "Already recording! Press your stop key." -i dialog-warning
      exit 1
    fi

    notify-send "Screen Recording" "Starting $local_mode recording…" -i video-x-generic

    BASE=(
      "$WL_SCREENREC"
      --encode-pixfmt nv12
      --low-power=off
      --dri-device "$RENDER_NODE"
      --framerate "$FPS"
    )
    [[ -n "$DURATION" ]] && BASE+=( --time "$DURATION" )

    if (( FORCE_CPU )); then
      ENCODER=(--no-hw --ffmpeg-encoder libx264 --ffmpeg-encoder-options "preset=veryfast,crf=20")
    else
      if (( PREFER_HEVC )); then
        ENCODER=(--ffmpeg-encoder hevc_vaapi --ffmpeg-encoder-options "profile=main,b=${BITRATE}")
      else
        ENCODER=(--ffmpeg-encoder h264_vaapi --ffmpeg-encoder-options "profile=main,b=${BITRATE}")
      fi
    fi

    case "$local_mode" in
      fullscreen)
        primary_output=$(hyprctl monitors -j | jq -r '.[0].name')
        CMD=("${BASE[@]}" "${ENCODER[@]}" --output "$primary_output" -f "$OUTPUT" "${EXTRA_WL_SR_OPTS[@]}")
        ;;
      region)
        if ! command -v slurp &>/dev/null; then
          notify-send "Error" "slurp is required for region selection." -i dialog-error
          exit 1
        fi
        region=$(slurp)
        CMD=("${BASE[@]}" "${ENCODER[@]}" -g "$region" -f "$OUTPUT" "${EXTRA_WL_SR_OPTS[@]}")
        ;;
      window)
        if command -v jq &>/dev/null; then
          window_info=$(hyprctl -j clients | jq -r '.[] | select(.focusHistoryID == 0) | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        fi
        if [[ -z "${window_info:-}" ]]; then
          if ! command -v slurp &>/dev/null; then
            notify-send "Error" "slurp is required for window selection fallback." -i dialog-error
            exit 1
          fi
          region=$(slurp)
          CMD=("${BASE[@]}" "${ENCODER[@]}" -g "$region" -f "$OUTPUT" "${EXTRA_WL_SR_OPTS[@]}")
        else
          CMD=("${BASE[@]}" "${ENCODER[@]}" -g "$window_info" -f "$OUTPUT" "${EXTRA_WL_SR_OPTS[@]}")
        fi
        ;;
    esac

    "${CMD[@]}" &
    rec_pid=$!
    echo "$rec_pid" > "$PIDFILE"
    sleep 0.2
    if ! ps -p "$rec_pid" >/dev/null 2>&1; then
      rm -f "$PIDFILE"
      notify-send "Error" "Failed to start recording (see terminal)." -i dialog-error
      exit 1
    fi
    update_status true "$start_time" "$local_mode"
    ;;

  *)
    echo "Usage: $0 [fullscreen|region|window|stop] [options]"
    exit 1
    ;;
esac
