#!/bin/bash
# Make github key and install dotfiles in $HOME with having git ssh configurated

DEFAULTPATH=${HOME}/dotfiles
file_name=${HOME}/.ssh/id_${HOSTNAME}_github

if [ -z ${SSH_VAR} ]; then
  SSH_OFF="1"
else
  SSH_OFF=${SSH_VAR}
fi

if [ -f $file_name ]; then
  SSH_OFF="1"
  SSH_FOUND="1"
else
  SSH_FOUND="0"
fi

if [ -z ${DOTFILES_SCRIPT_DIR} ]; then
  SCRIPT_PATH=$DEFAULTPATH
else
  SCRIPT_PATH=${DOTFILES_SCRIPT_DIR}
fi

echo "Script installation path set to $SCRIPT_PATH"

if [ "$SSH_OFF" == "0" ]; then
  i="1"
  if [ ! -f $file_name ]; then
    echo "Enter email id :"
    read email_id

    ssh-keygen -f $file_name -t rsa -C ${email_id}

    echo "Copy the ${file_name}.pub to Github"
    echo "Press any key to continue"
    read something
  fi

  echo "testing connection"
  ssh -T git@github.com -i ${file_name}

  if [ "$?" == "1" ]; then
    i="0"
  fi

  echo "value of i is $i"
  if [ "$i" != "0" ]; then
    while [ $i -ne 0 ]; do
      echo "Copy the ${file_name}.pub to Github"
      echo "Press any key to continue"
      read something

      echo "testing connection"
      ssh -T git@github.com -i ${file_name}

      if [ "$?" != "1" ]; then
        echo "Connection to github not setup yet"
        i="1"
      else
        i="0"
      fi
    done

    echo "Enter github username:"
    read username

    if [ ! -f $HOME/.ssh/config ]; then
      touch $HOME/.ssh/config
    fi

    if cat ~/.bashrc | grep -xqFe "host github.com"
    then
      echo "~/.ssh/config for github already exists"
    else
      echo "" >> $HOME/.ssh/config
      echo "host github.com" >> $HOME/.ssh/config
      echo "  User ${username}" >> $HOME/.ssh/config
      echo "  HostName github.com" >> $HOME/.ssh/config
      echo "  IdentityFile ~/.ssh/id_${HOSTNAME}_github" >> $HOME/.ssh/config
      echo "" >> $HOME/.ssh/config
    fi
  fi
fi

DOTFILES_DOWNLOAD="0"
if [ ! -d $SCRIPT_PATH ]; then
  git --version
  if [ "$?" != "0" ]; then
    echo "git not installed"
  else
    if [ "$SSH_OFF" == "0" ] || [ "$SSH_FOUND" == "1" ]; then
      git clone git@github.com:akshit-sharma/dotfiles.git $SCRIPT_PATH
      DOTFILES_DOWNLOAD="1"
    else
      git clone https://github.com/akshit-sharma/dotfiles.git $SCRIPT_PATH
      DOTFILES_DOWNLOAD="1"
    fi
  fi
else
  echo "$SCRIPT_PATH not an empty directory"
  echo "cannot clone"
fi

if [ -d $SCRIPT_PATH ]; then
  if [ "$DOTFILES_DOWNLOAD" == "1" ]; then
    source $SCRIPT_PATH/update.sh
  fi
fi

