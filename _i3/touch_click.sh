#!/bin/sh

touchpad_id=$(xinput list | awk '/Touchpad/{ for (i = 1; i <= NF; ++i) if (match($i, ".*=.*")) break; split($i, id, "="); print id[2] }')
[ "x${touchpad_id}" = "x" ] && exit 0
prop_id=$(xinput list-props ${touchpad_id} | awk '/Tapping Enabled \(/ { split($4, prop, "[()]"); print prop[2]; }')
xinput set-prop ${touchpad_id} ${prop_id} 1
