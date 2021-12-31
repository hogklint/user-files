#!/bin/bash
INTERNAL_MONITOR="eDP-1"
DP1="DP-1-2-8"
DP2="DP-1-2-1-8"
HDMI1="HDMI-1"

DP1="DP-1"
DP2="DP-2" # Right thunderbolt port
DP2="DP-3" # Left thunderbolt port

CONNECTED_MONITORS="$(xrandr | grep -E "\sconnected" | cut -d' ' -f1)"

function is_monitor()
{
    echo "$CONNECTED_MONITORS" | grep -w $1
}

if [ -n "$(is_monitor $DP1)" ] && [ -n "$(is_monitor $DP2)" ]
then
    xrandr --output $INTERNAL_MONITOR --off --output $DP1 --auto --pos 0x120 --output $DP2 --auto --rotate right --pos 2560x0
    echo "Dual: $DP1, $DP2"
elif [ -n "$(is_monitor $DP2)" ] && [ -n "$(is_monitor $HDMI1)" ]
then
    xrandr --output $DP2 --auto --primary --output $HDMI1 --auto --right-of $DP2 --rotate left --output $INTERNAL_MONITOR --off
    echo "Dual: $HDMI1, $DP2"
elif [ -n "$(is_monitor $DP1)" ] && [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $DP1 --auto --output $INTERNAL_MONITOR --auto --left-of $DP1
    echo "Dual: $INTERNAL_MONITOR, $DP1"
elif [ -n "$(is_monitor $DP2)" ] && [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $DP2 --auto --output $INTERNAL_MONITOR --off
    echo "Single: $DP2"
elif [ -n "$(is_monitor $HDMI1)" ] && [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    set -x
    #xrandr --output $HDMI1 --auto --output $INTERNAL_MONITOR --auto --left-of $HDMI1
    xrandr --output $HDMI1 --auto --output $INTERNAL_MONITOR --off
    # Scaling eDP-1
    #xrandr \
    #  --output $INTERNAL_MONITOR --auto \
    #  --output $HDMI1 --scale 1x1 --auto --left-of $INTERNAL_MONITOR
    #xrandr --dpi 276 \
    #  --output $INTERNAL_MONITOR \
    #  --output $HDMI1 --scale 2x2 --pos 3200x0 --panning 3840x2160+3200+0
    #xrandr --dpi 276 --fb 7040x3960 \
    #  --output eDP-1 --mode 3200x1800 \
    #  --output DP-1-2 --scale 2x2 --pos 3200x0 --panning 3840x2160+3200+0
    echo "Dual: $INTERNAL_MONITOR, $HDMI1"
elif [ -n "$(is_monitor $DP1)" ]
then
    xrandr --output $DP1 --auto
    echo "Single: $DP1"
elif [ -n "$(is_monitor $HDMI1)" ]
then
    xrandr --output $HDMI1 --auto
    echo "Single: $HDMI1"
elif [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $INTERNAL_MONITOR --auto --output $DP1 --off --output $DP2 --output $HDMI1 --off
    sleep 2
    xrandr --output $DP1 --off --output $DP2 --off --output $HDMI1 --off
    echo "Single: $INTERNAL_MONITOR"
fi

