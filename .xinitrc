#!/usr/bin/env bash

xset s off
xset -dpms
xset s noblank
xrandr --auto
exec i3
