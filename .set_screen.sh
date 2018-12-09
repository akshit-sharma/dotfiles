#!/bin/sh
#
# script for setting screens

xrandr --auto

display_args=""
hdmi_msg=""
dp_msg=""

xrandr --listmonitors | grep HDMI-0 > /dev/null
HDMI0_RET=$?

if [ $HDMI0_RET -eq 0 ]; then
  display_args="$display_args --output HDMI-0 --auto --left-of eDP-1-1"
  hdmi_msg="workspace 4, move workspace to output HDMI-0, workspace 3, move workspace to output HDMI-0"
fi

xrandr --listmonitors | grep DP-0 > /dev/null
DP0_RET=$?
xrandr --listmonitors | grep DP-1 > /dev/null
DP1_RET=$?

if [ $DP0_RET -eq 0 ]; then
  display_args="$display_args --output DP-0 --auto --right-of eDP-1-1"
  dp_msg="workspace 8, move workspace to output DP-0, workspace 7, move workspace to output DP-0"
  dp_msg="$dp_msg, workspace 4, move workspace to output DP-0, workspace 3, move workspace to output DP-0"
elif [ $DP1_RET -eq 0 ]; then
  display_args="$display_args --output DP-1 --rotate left --auto --right-of eDP-1-1"
  dp_msg="workspace 8, move workspace to output DP-1, workspace 7, move workspace to output DP-1"
fi

if [ "$display_args" != "" ]; then
  display_args="$display_args --output eDP-1-1"
  echo "xrandr $display_args"
  xrandr $display_args
fi

if [ "$hdmi_msg" != "" ]; then
  echo "i3-msg $hdmi_msg"
  i3-msg "$hdmi_msg" > /dev/null
fi

if [ "$dp_msg" != "" ]; then
  echo "i3-msg $dp_msg"
  i3-msg "$dp_msg" > /dev/null
fi

pgrep -x "feh" > /dev/null
PGREP_RET=$?
if [ $PGREP_RET -eq 1 ]; then
  feh --randomize --bg-fill ~/.config/i3/bgImages/*
  while sleep 600; do feh --randomize --bg-fill ~/.config/i3/bgImages/*; done &
fi

