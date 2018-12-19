#!/bin/bash
# Make github key and install dotfiles in $HOME with having git ssh configurated


DEFAULTPATH=${HOME}/dotfiles
file_name=${HOME}/.ssh/id_${HOSTNAME}_github
SSH_OFF="${SSH_OFF:-1}"

echo "SSH_OFF is set to ${SSH_OFF}"

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

wget --version > /dev/null
WGET_RET="$?"

# function for download and extracting a file to desired directory
# DOWNLOAD_HOME (1st parameter) : parent directory required for extracting file (e.g. $HOME/faaltu)
# DOWNLOAD_DIR  (2nd parameter) : full directory with extraction (e.g. $HOME/faaltu/clang+llvm-6.0.1....)
# DOWNLOAD_TAR  (3rd parameter) : path with tar file for downloading
# DOWNLOAD_URL  (4th parameter) : URL to download the tar file from
# DOWNLOAD_MD5  (5th paramter)  : MD5 hash of DOWNLOAD_TAR, check if existing file was corrupted or incomplete
function download_and_extract {
  DOWNLOAD_HOME="$1"
  DOWNLOAD_DIR="$2"
  DOWNLOAD_TAR="$3"
  DOWNLOAD_URL="$4"
  DOWNLOAD_MD5="$5"

  if [ $WGET_RET != 0 ]; then
    echo "Value of return from wget $WGET_RET"
    echo "Please make sure wget is installed"
    return
  fi

  if [[ $DOWNLOAD_DIR == $DOWNLOAD_HOME* ]]; then
    if [ -f "$DOWNLOAD_TAR" ]; then
      EXISTING_MD5=`eval md5sum $DOWNLOAD_TAR | cut -d' ' -f1`
      if [ "$DOWNLOAD_MD5" != "$EXISTING_MD5" ]; then
        echo "will have to redownload $DOWNLOAD_TAR"
        rm $DOWNLOAD_TAR
      fi   
    fi
    wget $DOWNLOAD_URL -O $DOWNLOAD_TAR
    if [ -d "$DOWNLOAD_DIR" ]; then
      rm -rf $DOWNLOAD_DIR
    fi
    if [ ! -d "$DOWNLOAD_HOME" ]; then
      mkdir -p $DOWNLOAD_HOME
    fi
    if [[ $DOWNLOAD_TAR == *.xz ]]; then
      tar -xf $DOWNLOAD_TAR -C $DOWNLOAD_HOME
    elif [[ $DOWNLOAD_TAR == *.gz ]]; then
      tar -zxf $DOWNLOAD_TAR -C $DOWNLOAD_HOME
    else 
      echo "Don't know how to extract $DOWNLOAD_TAR"
    fi
  else
    echo "DOWNLOAD_HOME is $DOWNLOAD_HOME"
    echo "DOWNLOAD_DIR is $DOWNLOAD_DIR"
    echo "DOWNLOAD_DIR should start with same string as DOWNLOAD_HOME"
  fi
}

# install git large file system (git lfs) if not installed or version updated
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing git lfs"
  fi
  GIT_LFS_MD5="a8363aba7fa60e1769571c4f49affbcb"
  GIT_LFS_VER="2.5.1"
  GIT_LFS_DIR="git-lfs"
  GIT_LFS_TAR="git-lfs-linux-amd64-v${GIT_LFS_VER}.tar.gz"
  GIT_LFS_URL="https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VER}/${GIT_LFS_TAR}"
  GIT_LFS_INSTALL="1"

  GIT_LFS_INSTALL_SUCC="1"
  if [ $WGET_RET == 0 ]; then
    git lfs --version 
    if [ "$?" != 0 ]; then
      echo "git lfs not found"
      # download and install lfs
      GIT_LFS_INSTALL="0"
    else 
      echo "git lfs already found"
      INSTALLED_VER=`eval git lfs --version | cut -d' ' -f1 | cut -d'/' -f2`
      if [ "$GIT_LFS_VER" != "$INSTALLED_VER" ]; then
        # version different need removal, download and install
        GIT_LFS_INSTALL="0"
      else 
        GIT_LFS_INSTALL_SUCC="0"
      fi
    fi
  else
    echo "wget not found, cannot download git lfs"
  fi
  GIT_LFS_INSTALL="1" # bypassing git lfs install
  if [ $GIT_LFS_INSTALL == 0 ]; then
    echo "install of git lfs set to true"
    download_and_extract /tmp/faaltu/$GIT_LFS_DIR /tmp/faaltu/$GIT_LFS_DIR $GIT_LFS_TAR $GIT_LFS_URL $GIT_LFS_MD5
    if [ -f /tmp/faaltu/$GIT_LFS_DIR/install.sh ]; then
      PREFIX=$HOME /tmp/faaltu/$GIT_LFS_DIR/install.sh
      # if [ -d $SCRIPT_PATH ]; then
      #   git -C $SCRIPT_PATH lfs install 
      # fi
      GIT_LFS_INSTALL_SUCC="0"
    else
      echo "/tmp/faaltu/$GIT_LFS_DIR/install.sh not found"
      echo "git lfs install unsuccessful"
    fi
  fi

DOTFILES_DOWNLOAD="0"
if [ ! -d $SCRIPT_PATH ]; then
  git --version
  if [ "$?" != "0" ]; then
    echo "git not installed"
  else
    if [ "$GIT_LFS_INSTALL_SUCC" == 0 ]; then
      git lfs clone git@github.com:akshit-sharma/dotfiles.git $SCRIPT_PATH
      DOTFILES_DOWNLOAD="1"
    else
      if [ "$SSH_OFF" == "0" ]; then
        git clone git@github.com:akshit-sharma/dotfiles.git $SCRIPT_PATH
        DOTFILES_DOWNLOAD="1"
      else
        git clone https://github.com/akshit-sharma/dotfiles.git $SCRIPT_PATH
        DOTFILES_DOWNLOAD="1"
      fi
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

