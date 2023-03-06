#!/bin/bash
INTERNAL_MONITOR="eDP-1"
HDMI1="HDMI-1"
# Dock in right thunderbolt
DP1="DP-2-3"
DP2="DP-2-1"
# Dock in left thunderbolt
DP3="DP-3-3"
DP1="DP-3-1"
DP2="DP-3-2"

CONNECTED_MONITORS="$(xrandr | grep -E "\sconnected" | cut -d' ' -f1)"

function is_monitor()
{
    echo "$CONNECTED_MONITORS" | grep -w $1
}

if [ -n "$(is_monitor $DP3)" ] && [ -n "$(is_monitor $DP2)" ]
then
    xrandr --output $DP3 --auto --primary --output $DP2 --auto --right-of $DP3 --rotate right --output $INTERNAL_MONITOR --off
    echo "Dual: $DP3, $DP2"
elif [ -n "$(is_monitor $DP2)" ] && [ -n "$(is_monitor $HDMI1)" ]
then
    xrandr --output $DP2 --auto --primary --output $HDMI1 --auto --right-of $DP2 --rotate left --output $INTERNAL_MONITOR --off
    echo "Dual: $HDMI1, $DP2"
elif [ -n "$(is_monitor $DP3)" ] && [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $DP3 --auto --output $INTERNAL_MONITOR --auto --left-of $DP3
    echo "Dual: $INTERNAL_MONITOR, $DP3"
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
elif [ -n "$(is_monitor $DP3)" ]
then
    xrandr --output $DP3 --auto
    echo "Single: $DP3"
elif [ -n "$(is_monitor $DP2)" ]
then
    xrandr --output $DP2 --auto
    echo "Single: $DP2"
elif [ -n "$(is_monitor $HDMI1)" ]
then
    xrandr --output $HDMI1 --auto
    echo "Single: $HDMI1"
elif [ -n "$(is_monitor $INTERNAL_MONITOR)" ]
then
    xrandr --output $INTERNAL_MONITOR --auto --output $DP3 --off --output $DP1 --output $HDMI1 --off
    sleep 2
    xrandr --output $DP3 --off --output $DP1 --off --output $HDMI1 --off
    echo "Single: $INTERNAL_MONITOR"
fi

