#!/bin/bash

set -eu

id=$(xinput list | sed -n '/AlpsPS\/2 ALPS GlidePoint/s/.*id=\([0-9]\+\).*/\1/p')

palmDetection=$(xinput list-props "$id" | sed -n '/Synaptics Palm Detection (/s/.*(\([0-9]\+\)).*/\1/p')

speed=$(xinput list-props "$id" | sed -n '/Synaptics Move Speed (/s/.*(\([0-9]\+\)).*/\1/p')

xinput set-prop "$id" "$palmDetection" 1
xinput set-prop "$id" "$speed" 2.0 133.0 0.1 0.0 

