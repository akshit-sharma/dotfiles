#!/bin/bash
# 

if [ ! -z "$DISPLAY" ]; then
  echo "Detected Display: $DISPLAY"
  if [ ! -d $HOME/Softwares/quicktile ]; then

    sudo apt-get install python python-gtk2 python-xlib python-dbus python-wnck python-setuptools
   
    git clone git@github.com:ssokolow/quicktile.git $HOME/Softwares/quicktile

    cd $HOME/Softwares/quicktile
    ./install.sh
    cd $HOME/dotfiles/primary.conf

  fi
else
  echo "No display detected"
fi

