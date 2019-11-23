#!/bin/sh
#
# script for setting screens

xrandr --auto

display_args=""
hdmi_msg=""
dp_msg=""

PORTRAIT_DISPLAY=`xrandr --listmonitors | grep 510 | grep 287 | cut -d' ' -f6`
OFFICE_LEFT=`xrandr --listmonitors | grep 550 | grep 340 |  cut -d' ' -f6`
MAIN_DISPLAY=`xrandr --listmonitors | grep 344 | grep 193 | cut -d' ' -f6`
MAIN_HOME=`xrandr --listmonitors | grep 597 | grep 336 | cut -d' ' -f6`

# echo "Value of PORTRAIT_DISPLAY is $PORTRAIT_DISPLAY"
# echo "Value of OFFICE_LEFT is $OFFICE_LEFT"
# echo "Value of MAIN_DISPLAY is $MAIN_DISPLAY"

# xrandr --listmonitors | grep HDMI-0 > /dev/null
# HDMI0_RET=$?

# xrandr --listmonitors | grep eDP-1 > /dev/null
# eDP1_RET=$?
# xrandr --listmonitors | grep eDP-1-1 > /dev/null
# eDP11_RET=$?

# xrandr --listmonitors | grep +DP-0 > /dev/null
# DP0_RET=$?
# xrandr --listmonitors | grep 1920/510x1080/287 > /dev/null
# DP0_ROT=$?
# xrandr --listmonitors | grep +DP-1-1 > /dev/null
# DP11_RET=$?
# xrandr --listmonitors | grep +DP-1 > /dev/null
# DP1_RET=$?

if [ -z $MAIN_DISPLAY ];  then
  MAIN_DISPLAY=`xrandr --listmonitors | grep 345 | grep 194 | cut -d' ' -f6`
  if [ -z $MAIN_DISPLAY ]; then
    echo "Main Display unkown"
    exit 2
  fi
fi

if [ ! -z "$PORTRAIT_DISPLAY" ]; then
  display_args="$display_args --output $PORTRAIT_DISPLAY --rotate left --auto --right-of $MAIN_DISPLAY"
  dp_msg="workspace 8, move workspace to output $PORTRAIT_DISPLAY, workspace 7, move workspace to output $PORTRAIT_DISPLAY"
fi

if [ ! -z "$MAIN_HOME" ]; then
  display_args="$display_args --output $MAIN_HOME --auto --right-of $MAIN_DISPLAY"
  dp_msg="workspace 8, move workspace to output $MAIN_HOME, workspace 7, move workspace to output $MAIN_HOME" 
fi

if [ ! -z "$OFFICE_LEFT" ]; then
  display_args="$display_args --output $OFFICE_LEFT --auto --left-of $MAIN_DISPLAY"
  hdmi_msg="workspace 4, move workspace to output $OFFICE_LEFT, workspace 3, move workspace to output $OFFICE_LEFT"
fi

# if [ $HDMI0_RET -eq 0 ]; then
#   display_args="$display_args --output HDMI-0 --auto --left-of $MAIN_DISPLAY"
#   hdmi_msg="workspace 4, move workspace to output HDMI-0, workspace 3, move workspace to output HDMI-0"
# fi

# if [ $DP0_RET -eq 0 ]; then
#   ROTATE=""
#   if [ $DP0_ROT -eq 0 ]; then
#     ROTATE=" --rotate left "
#   fi
# #  display_args="$display_args --output DP-0 --rotate left --auto --right-of $MAIN_DISPLAY"
#   display_args="$display_args --output DP-0 $ROTATE --auto --right-of $MAIN_DISPLAY"
#   dp_msg="workspace 8, move workspace to output DP-0, workspace 7, move workspace to output DP-0"
#   # dp_msg="$dp_msg, workspace 4, move workspace to output DP-0, workspace 3, move workspace to output DP-0"
# elif [ $DP11_RET -eq 0 ]; then
#   display_args="$display_args --output DP-1-1 --auto --right-of $MAIN_DISPLAY"
#   dp_msg="workspace 8, move workspace to output DP-1-1, workspace 7, move workspace to output DP-1-1" 
# elif [ $DP1_RET -eq 0 ]; then
#   display_args="$display_args --output DP-1 --rotate left --auto --right-of MAIN_DISPLAY"
#   dp_msg="workspace 8, move workspace to output DP-1, workspace 7, move workspace to output DP-1"
# fi

if [ "$display_args" != "" ]; then
  display_args="$display_args --output $MAIN_DISPLAY"
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

# pgrep -x "feh" > /dev/null
# PGREP_RET=$?
# if [ $PGREP_RET -eq 1 ]; then
#   feh --randomize --bg-fill ~/.config/i3/bgImages/*
#   while sleep 600; do feh --randomize --bg-fill ~/.config/i3/bgImages/*; done &
# fi

