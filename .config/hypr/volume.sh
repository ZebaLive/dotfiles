#!/bin/sh

mutecmd() {
  wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
}

upcmd() {
  wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
}

downcmd() {
  wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
}

if [ "$1" = "mute" ]; then
  mutecmd
elif [ "$1" = "up" ]; then
  upcmd
else
  downcmd
fi

volume="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2*100}')"
mute="$(pactl get-sink-mute 0 | awk '{print $2}')"

if [ "$mute" = "yes" ]; then
  # Show the sound muted notification
  notify-send -a "wp-vol" "Volume muted" --expire-time=1000
else
  # Show the volume notification
  notify-send -a "wp-vol" -h int:value:"$volume" "Volume: ${volume}" --expire-time=1000
fi
