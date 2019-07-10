#!/bin/bash
#
# script for setting wallpapers

function set_wallpaper() 
{
  sleep 60; feh --randomize --bg-center ~/.config/i3/bgImages/*
  while sleep 600; do feh --randomize --bg-center ~/.config/i3/bgImages/*; done &
}

type feh > /dev/null
FEH_RET=$?
if [ $FEH_RET -eq 0 ]; then
  set_wallpaper
else
  echo "feh not installed, cannot set wallpaper"
fi

