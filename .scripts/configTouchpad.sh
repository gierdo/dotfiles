#!/bin/bash

set -eu

id=$(xinput list | sed -n '/SynPS\/2 Synaptics TouchPad/s/.*id=\([0-9]\+\).*/\1/p')


naturalScroll=$(xinput list-props "$id" | sed -n '/Natural Scrolling Enabled (/s/.*(\([0-9]\+\)).*/\1/p')

click=$(xinput list-props "$id" | sed -n '/libinput Click Method Enabled (/s/.*(\([0-9]\+\)).*/\1/p')

tap=$(xinput list-props "$id" | sed -n '/libinput Tapping Enabled (/s/.*(\([0-9]\+\)).*/\1/p')


xinput set-int-prop "$id" "$naturalScroll" 8 1
xinput set-prop "$id" "$click" 0 1
xinput set-prop "$id" "$tap" 1

