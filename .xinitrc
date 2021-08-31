#!/usr/bin/env bash

xset s off
xset -dpms
xset s noblank
xrandr --auto
export WINIT_X11_SCALE_FACTOR=1
exec dbus-launch i3
