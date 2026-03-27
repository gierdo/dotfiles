#!/bin/sh
pkill swaybg 2>/dev/null
pkill -f 'wallpaper-term\.py' 2>/dev/null
sleep 0.3

SCRIPT="$(dirname "$0")/wallpaper-term.py"

swaybg -m solid-color -c '#002b36' &
BG_PID=$!

python3 "$SCRIPT" "$@" &
PID=$!
sleep 1

kill "$BG_PID" 2>/dev/null

if kill -0 "$PID" 2>/dev/null; then
  wait "$PID"
else
  exec swaybg -m fill -i ~/.dotfiles/themes/wallpaper.png
fi
