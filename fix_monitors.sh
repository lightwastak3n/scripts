#!/usr/bin/env bash
# Connecting TV through HDMI screws up everything

primary="HDMI-A-0"
left="DisplayPort-0"
tv="HDMI-A-1"

# Align left - primary - tv
xrandr --output $left --auto --pos 0x0
xrandr --output $primary --auto --pos 1440x0
# TV defaults to 4k, too small, change to fullhd
xrandr --output $tv --mode 1920x1080 --pos 3360x0
