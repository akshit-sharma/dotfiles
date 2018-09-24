# /bin/bash

NEED_VIM_PLUGIN_INSTALL=1
NEED_BASH_REFRESH=0
NEED_ENTRY_REFRESH=0

DEBUG_SCRIPT=1

# function for returning the parent directory of this script
function parent_directory {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    TARGET="$(readlink "$SOURCE")"
    if [[ $TARGET == /* ]]; then
      if [ DEBUG_SCRIPT -ne 0]; then
        echo "SOURCE '$SOURCE' is an absolute symlink to '$TARGET'"
      fi
      SOURCE="$TARGET"
    else
      DIR="$( dirname "$SOURCE" )"
      if [[ DEBUG_SCRIPT -ne 0 ]]; then
        echo "SOURCE '$SOURCE' is a relative symlink to '$TARGET' (relative to '$DIR')"
      fi
      SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, 
                            # we need to resolve it relative to the path where the symlink file was located
    fi
  done
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "SOURCE is '$SOURCE'"
  fi
  RDIR="$( dirname "$SOURCE" )"
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  if [ "$DIR" != "$RDIR" ] && [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "DIR '$RDIR' resolves to '$DIR'"
  fi
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "DIR is '$DIR'"
  fi
  SCRIPT_PARENT_DIRECTORY=$DIR
}

# function for adding lines to ~/.bashrc if not present
# 1: LINE to change to if not present
# 2: Initial value of Refresh
# 3: Debug msg to print if present
# 4: CMD to achive desired LINE (only if updating LINE instead of adding LINE) 
function update_bashrc {
  LINE=$1
  REFRESH=$2
  MSG_IF_PRESENT="${3:-3rd paramater to update_bashrc not given, no debug stmt}"
  CMD="${4:-$LINE}"

  if cat ~/.bashrc | grep -xqFe "$LINE"
  then
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "~/.bashrc $MSG_IF_PRESENT"
    fi
  else
    if [ "$LINE" = "$CMD" ]; then 
      echo "" >> ~/.bashrc
      echo "$LINE" >> ~/.bashrc
    else 
      eval $CMD
    fi
    REFRESH=1
  fi
}

if [ ! "$DOTFILES_SCRIPT_PARENT" ]; then
  parent_directory
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "Found parent directory as $SCRIPT_PARENT_DIRECTORY"
  fi
  SCRIPTPATH=$SCRIPT_PARENT_DIRECTORY
else
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "DOTFILES_SCRIPT_PARENT already set to $DOTFILES_SCRIPT_PARENT"
  fi
  SCRIPTPATH=$DOTFILES_SCRIPT_PARENT
fi

if [ -z "$1" ]; then
  NEED_ENTRY_REFRESH=1
else
  NEED_ENTRY_REFRESH=0
fi

# if called by other script
if [ $SHLVL -gt 2 ]; then  
  if [ -z "$2" ]; then
    NEED_VIM_PLUGIN_INSTALL=1
  else
    NEED_VIM_PLUGIN_INSTALL=0
  fi
fi

# function for creating symlink to files in $HOME/$dir
function home_dir_symlink {
  filename="$1"
  dir="${2:-}"
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "symlink $HOME/$dir/$filename ---> $SCRIPTPATH/$filename"
  fi
  if [ ! -d $HOME/$dir ]; then
    mkdir -p $HOME/$dir
  fi
  if [ ! -f $SCRIPTPATH/$filename ] && [ ! -d $SCRIPTPATH/$filename ]; then 
                                                            # pretty much use less after getting files
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "copying $HOME/$dir/$filename to $SCRIPTPATH/$filename"
    fi
    if [ -f $HOME/$dir/$filename ]; then
      cp $HOME/$dir/$filename $SCRIPTPATH/$filename   # usefull to add new files in the script
                                                      # instead of manually moving/copying
    elif [ -d $HOME/$dir/$filename ]; then
      cp -r $HOME/$dir/$filename $SCRIPTPATH/$filename
    else 
      echo "don't know how to backup $HOME/$dir/$filename"
      echo "return ............."
      return
    fi
  fi                                                   
  if [ ! -L "$HOME/$dir/$filename" ]; then
    if [ -d "$HOME/$dir/$filename" ] || [ -f "$HOME/$dir/$filename" ]; then
#  script_file_md5=`eval md5sum < $SCRIPTPATH/$filename | cut -d\  -f1`
#  destination_file_md5=`eval md5sum < $SCRIPTPATH/$filename | cut -d\  -f1`
      if [ ! -f "$HOME/$dir/$filename.bk" ] && [ ! -d "$HOME/$dir/$filename.bk" ] && [ ! -L "$HOME/$dir/$filename.bk" ]; then
        if [[ DEBUG_SCRIPT -ne 0 ]]; then
          echo "backing up $HOME/$dir/$filename to $HOME/$dir/$filename.bk"
        fi
        mv "$HOME/$dir/$filename" "$HOME/$dir/$filename.bk"
      else
        echo "$HOME/$dir/$filename.bk already present skipping backup"
      fi
    fi
    if [ ! -L "$HOME/$dir/$filename" ]; then
      if [[ DEBUG_SCRIPT -ne 0 ]]; then
        echo "linking $SCRIPTPATH/$filename to $HOME/$dir/$filename"
      fi
      ln -sT $SCRIPTPATH/$filename $HOME/$dir/$filename
    fi
  fi
}


# script for adding llvm to environment
home_dir_symlink llvm_scripts .
# script for adding gcc to environment
home_dir_symlink gcc_scripts .

# manual linking of files for ~/.vim/syntax dir
home_dir_symlink vulkan1.0.vim .vim/syntax

# symlink directory for vimwiki
home_dir_symlink vimwiki .

# if kde plasma get my shortcuts
if [[ $DESKTOP_SESSION = *"plasma" ]]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "plasma (kde) detected"
  fi
  PLASMASHELL_VERSION=`eval plasmashell --version | sed -nr 's/plasmashell ([0-9][0-9]*\.*)/\1/p'`
  PLASMASHELL_MAJOR=`plasmashell --version | sed -rn 's/plasmashell ([0-9])\.[0-9].*/\1/p'`
  if [ $PLASMASHELL_MAJOR -eq 5 ]; then
    home_dir_symlink kglobalshortcutsrc.kksrc .config
    home_dir_symlink khotkeysrc .config
    home_dir_symlink quicktile.cfg .config
    home_dir_symlink Xmodmap .config
  else
    echo "Don't know how to handle this plasma version"
    echo "PLASMASHELL_VERSION $PLASMASHELL_VERSION"
    echo "PLASMASHELL_MAJOR $PLASMASHELL_VERSION"
    OUTPUT_PLASMASHELL=`eval plasmashell --version`
    echo "plasmashell --version is $OUTPUT_PLASMASHELL"
  fi
else
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "desktop session not plasma ($DESKTOP_SESSION)"
  fi
fi

# plugin manager for vim
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
  NEED_VIM_PLUGIN_INSTALL=1
fi

home_dir_symlink .vimrc .
home_dir_symlink .my_ssh_agent .
home_dir_symlink .my_profile .
home_dir_symlink .my_bashrc .
home_dir_symlink .my_entry .
home_dir_symlink .tmux.conf .
  
if [ ! -f "$HOME/.my_vars" ]; then
  touch $HOME/.my_vars
fi


mkdir -p ~/.vim/tags

# setup virtualenv for python2 and python3
function python_virtualenv_setup {
  VERSION_NUMBER="$1"
  VIRTUALENV_EXEC="virtualenv"

  if [ -d "$HOME/venv" ]; then
    if [ "$VERSION_NUMBER" == "3" ]; then
      echo "virtualenv for python3 exists ($HOME/venv)"
      return
    fi
  fi

  if [ -d "$HOME/venv2" ]; then
    if [ "$VERSION_NUMBER" == "2" ]; then
      echo "virtualenv for python2 exists ($HOME/venv2)"
      return
    fi
  fi

  $VIRTUALENV_EXEC --version
  if [ "$?" != "0" ]; then
    #virtualenv not in path    
    if [ ! -f $HOME/.local/bin/virtualenv ]; then
      # /usr/bin/python3
      if [ ! -f /usr/bin/python3 ] && [ ! -L /usr/bin/python3 ]; then
        echo "From python_virtualenv_setup: Cannot find /usr/bin/python3"
        echo "Cannot create virtualenv"
        return
      else
        /usr/bin/python3 -m pip install --user virtualenv
        VIRTUALENV_EXEC="$HOME/.local/bin/virtualenv"
        if [ "$?" != "0" ]; then
          echo "Error in installing virtualenv through pip"
          echo "Command tried"
          echo "/usr/bin/python3 -m pip install --user virtualenv"
          return
        fi
      fi
    fi
  fi
  # virtualenv should be in VIRTUALENV_EXE at this point
  if [ "$VERSION_NUMBER" != "2" ] && [ "$VERSION_NUMBER" != "3" ]; then
    echo "From python_virtualenv_setup: $VERSION_NUMBER is not supported"
    return
  else
    if [ "$VERSION_NUMBER" == "2" ]; then
      # /usr/bin/python2
      if [ ! -f /usr/bin/python2 ] && [ ! -L /usr/bin/python2 ]; then
        echo "From python_virtualenv_setup: Cannot find /usr/bin/python2"
      else
        $VIRTUALENV_EXEC -p /usr/bin/python2 $HOME/venv2
      fi
    elif [ "$VERSION_NUMBER" == "3" ]; then
      # /usr/bin/python3
      if [ ! -f /usr/bin/python3 ] && [ ! -L /usr/bin/python3 ]; then
        echo "From python_virtualenv_setup: Cannot find /usr/bin/python3"
      else
        $VIRTUALENV_EXEC -p /usr/bin/python3 $HOME/venv
      fi
    fi
  fi
}

python_virtualenv_setup 2
python_virtualenv_setup 3


# all symlink done (configuration structure established)

update_bashrc "^force_color_prompt=yes" $NEED_BASH_REFRESH "force_color_prompt already set" \
              "sed -i 's/#force_color_prompt/force_color_prompt/g' ~/.bashrc"
NEED_BASH_REFRESH=$REFRESH

update_bashrc DOTFILES_SCRIPT_PARENT=$SCRIPTPATH $NEED_BASH_REFRESH "DOTFILES_SCRIPT_PARENT env var set"
NEED_BASH_REFRESH=$REFRESH

update_bashrc "export DOTFILES_SCRIPT_PARENT" $NEED_BASH_REFRESH "DOTFILES_SCRIPT_PARENT env already exported"
NEED_BASH_REFRESH=$REFRESH

update_bashrc "source ~/.my_profile" $NEED_ENTRY_REFRESH "removing source ~/.my_bashrc" \
              "sed -i '/source ~\/.my_profile/d' ~/.bashrc"

update_bashrc "source ~/.my_entry" $NEED_ENTRY_REFRESH "already calling ~/.my_entry" 
NEED_ENTRY_REFRESH=$REFRESH


  echo "bef val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"

if [[ NEED_BASH_REFRESH -ne 0 ]]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing bashrc"
  fi
  #source ~/.bashrc # cannot source bashrc from script
  source ~/.my_entry "$SCRIPTPATH"
  NEED_ENTRY_REFRESH=0
fi

echo "after bash of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"

if [[ NEED_ENTRY_REFRESH -ne 0 ]]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing my_entry"
  fi
  source ~/.my_entry
fi

echo "after prof val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_ENTRY_REFRESH"

if [[ NEED_VIM_PLUGIN_INSTALL -ne 0 ]]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "running vim +PluginInstall...."
  fi
  VIM_PLUGIN_HASH=$(cat $HOME/.vimrc | sed -n 's/\(^Plugin\)/\1/p' | md5sum | cut -d' ' -f1)
  if [ ! -f $SCRIPTPATH/faaltu/.vim_plugin.hash ]; then
    VIM_PLUGIN_OLD_HASH="Nothing"
    vim +PluginInstall +qall
  else
    VIM_PLUGIN_OLD_HASH=$(cat $SCRIPTPATH/faaltu/.vim_plugin.hash)
  fi
  if [ "$VIM_PLUGIN_HASH" != "$VIM_PLUGIN_OLD_HASH" ]; then
    vim +PluginClean! +qall
    vim +PluginInstall +qall
    vim +PluginUpdate +qall
    echo $VIM_PLUGIN_HASH > $SCRIPTPATH/faaltu/.vim_plugin.hash
  fi

fi

# install YouCompleteMe only if not installed or if YCM is updated
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing YouCompleteMe"
  fi
  make --version
  MAKE_RET=$?
  cmake --version
  CMAKE_RET=$?
  if [ $MAKE_RET -eq 0 ] && [ $CMAKE_RET -eq 0 ]; then
    if [ -f $HOME/.vim/bundle/YouCompleteMe/install.py ]; then
      YCM_HASH=$(git -C $HOME/.vim/bundle/YouCompleteMe/ rev-parse @)
      if [ ! -f $SCRIPTPATH/faaltu/.clang+llvm.hash ]; then
        YCM_OLD_HASH="Nothing"
      else
        YCM_OLD_HASH=$(cat $SCRIPTPATH/faaltu/.clang+llvm.hash)
      fi
      if [ "$YCM_HASH" != "$YCM_OLD_HASH" ]; then
        $HOME/.vim/bundle/YouCompleteMe/install.py --clang-completer --java-completer
        echo $YCM_HASH > $SCRIPTPATH/faaltu/.clang+llvm.hash
      else 
        echo "YouCompleteMe is latest"
      fi
    fi
  fi

wget --version > /dev/null
WGET_RET="$?"

# function for download and extracting a file to desired directory
# DOWNLOAD_HOME (1st parameter) : parent directory required for extracting file (e.g. $HOME/faaltu)
# DOWNLOAD_DIR  (2nd parameter) : full directory with extraction (e.g. $HOME/faaltu/clang+llvm-6.0.1....)
# DOWNLOAD_TAR  (3rd parameter) : tar file for downloading
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
    if [ -f "$DOWNLOAD_HOME/$DOWNLOAD_TAR" ]; then
      EXISTING_MD5=`eval md5sum $DOWNLOAD_TAR | cut -d' ' -f1`
      if [ "$DOWNLOAD_MD5" != "$EXISTING_MD5" ]; then
        echo "will have to redownload $DOWNLOAD_TAR"
        rm $DOWNLOAD_TAR
      fi   
    fi
    wget $DOWNLOAD_URL -O $DOWNLOAD_HOME/$DOWNLOAD_TAR
    if [ -d "$DOWNLOAD_DIR" ]; then
      rm -rf $DOWNLOAD_DIR
    fi
    if [ ! -d "$DOWNLOAD_HOME" ]; then
      mkdir -p $DOWNLOAD_HOME
    fi
    if [[ $DOWNLOAD_HOME/$DOWNLOAD_TAR == *.xz ]]; then
      tar -xf $DOWNLOAD_HOME/$DOWNLOAD_TAR -C $DOWNLOAD_HOME
    elif [[ $DOWNLOAD_HOME/$DOWNLOAD_TAR == *.gz ]]; then
      tar -zxf $DOWNLOAD_HOME/$DOWNLOAD_TAR -C $DOWNLOAD_HOME
    else 
      echo "Don't know how to extract $DOWNLOAD_TAR"
    fi
  else
    echo "DOWNLOAD_HOME is $DOWNLOAD_HOME"
    echo "DOWNLOAD_DIR is $DOWNLOAD_DIR"
    echo "DOWNLOAD_DIR should start with same string as DOWNLOAD_HOME"
  fi
}

# # install vim only if update is available
#   if [[ DEBUG_SCRIPT -ne 0 ]]; then
#     echo "installing/updating vim"
#   fi
#   VIM_DIR="vim"
#   VIM_REPO=$SCRIPTPATH/faaltu/$VIM_DIR
#   VIM_INSTALL=0
#   if [ ! -d $VIM_REPO ]; then
#     git clone https://github.com/vim/vim.git $VIM_REPO
#     VIM_INSTALL=1
#   fi
#   git -C $VIM_REPO remote update
#
#   VIM_UPSTREAM='@{u}'
#   VIM_LOCAL=$(git -C $VIM_REPO rev-parse @)
#   VIM_REMOTE=$(git -C $VIM_REPO rev-parse "$UPSTREAM")
#   VIM_BASE=$(git -C $VIM_REPO merge-base @ "$UPSTREAM")
#
#   if [ $LOCAL = $BASE ] && [[ ! ($LOCAL = $REMOTE) ]]; then
#     echo "vim update available"
#     git -C $VIM_REPO pull origin master
#     make -C $VIM_REPO distclean
#     VIM_INSTALL=1
#   fi
#   if [ $VIM_INSTALL == 1 ]; then
#     (cd $VIM_REPO && ./configure --enable-pythoninterp --prefix=$HOME/.local)
#     make -C $VIM_REPO -j 8
#     make -C $VIM_REPO install
#   fi


# install ctags only if not installed or MD5 changed
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing ctags"
  fi
  if [ $WGET_RET == 0 ]; then
    CTAGS_CORRECT_MD5="c00f82ecdcc357434731913e5b48630d"
    CTAGS_VER="5.8"
    CTAGS_DIR="ctags-${CTAGS_VER}"
    CTAGS_TAR="ctags-${CTAGS_VER}.tar.gz"
    CTAGS_URL="https://superb-dca2.dl.sourceforge.net/project/ctags/ctags/${CTAGS_VER}/${CTAGS_TAR}"
    CTAGS_INSTALL="0"
  
    ctags --version > /dev/null
    CTAGS_RET="$?"

    if [[ $CTAGS_RET != 0 ]]; then

      if [ ! -f "$SCRIPTPATH/faaltu/$CTAGS_TAR" ]; then
        download_and_extract $SCRIPTPATH/faaltu/ $SCRIPTPATH/faaltu/$CTAGS_DIR $CTAGS_TAR $CTAGS_URL $CTAGS_MD5
        CTAGS_INSTALL=1
      fi
      if [[ $CTAGS_INSTALL == 1 ]]; then
        if [ -f "$SCRIPTPATH/faaltu/$CTAGS_DIR/configure" ]; then
          (cd $SCRIPTPATH/faaltu/$CTAGS_DIR/ && ./configure --prefix=$HOME)
          make -C $SCRIPTPATH/faaltu/$CTAGS_DIR 
          make -C $SCRIPTPATH/faaltu/$CTAGS_DIR install
        else
          echo "$SCRIPTPATH/faaltu/$CTAGS_DIR/configure not found"
        fi
      fi

  
    else 
      echo "CTAGS found, not installing again"
    fi

  fi

# install clang+llvm only if not installed or MD5 changed
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing clang+llvm"
  fi
  if [ $WGET_RET == 0 ]; then 
    echo "wget found"
    LLVM_CORRECT_MD5="661fa37f6557d9544ed950d40c05a6fa"
    LLVM_PREBINARY_VER="6.0.1"
    LLVM_PREBINARY_DIR="clang+llvm-${LLVM_PREBINARY_VER}-x86_64-linux-gnu-ubuntu-16.04"
    LLVM_PREBINARY_TAR="${LLVM_PREBINARY_DIR}.tar.xz"
    LLVM_PREBINARY_URL="http://releases.llvm.org/${LLVM_PREBINARY_VER}/${LLVM_PREBINARY_TAR}"
    LLVM_INSTALL="1"
    
    if [ ! -L "$SCRIPTPATH/faaltu/clang+llvm" ]; then
      # symlink not found, worst case download and install
      LLVM_INSTALL="0"
    else
      # symlink found, checking version next
      LLVM_INSTALL_VER=`eval $SCRIPTPATH/faaltu/clang+llvm/bin/clang --version | head -n1 | cut -d' ' -f3`
      if [ "$LLVM_INSTALL_VER" != "$LLVM_PREBINARY_VER" ]; then
        # version different need removal, download and install
        LLVM_INSTALL="0"
      else
        # up-to date
        echo "LLVM up-to date"
      fi
    fi
    if [ $LLVM_INSTALL == 0 ]; then
      if [ -L $SCRIPTPATH/faaltu/clang+llvm ]; then
        rm $SCRIPTPATH/faaltu/clang+llvm
      fi
      download_and_extract $SCRIPTPATH/faaltu $SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR $LLVM_PREBINARY_TAR $LLVM_PREBINARY_URL $LLVM_CORRECT_MD5
    fi
    if [ ! -L $SCRIPTPATH/faaltu/clang+llvm ]; then
      ln -sT $SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR $SCRIPTPATH/faaltu/clang+llvm
    else 
      LLVM_CURRENT_LINK=`eval readlink -f $SCRIPTPATH/faaltu/clang+llvm`
      if [ "$LLVM_CURRENT_LINK" != "$SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR" ]; then
        rm $SCRIPTPATH/faaltu/clang+llvm
        ln -sT $SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR $SCRIPTPATH/faaltu/clang+llvm
      fi
    fi
  else 
    echo "wget not found, cannot download LLVM Pre Binary"
  fi

# install git large file system (git lfs) if not installed or version updated
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "installing git lfs"
  fi
  GIT_LFS_MD5="a8363aba7fa60e1769571c4f49affbcb"
  GIT_LFS_VER="2.5.1"
  GIT_LFS_DIR="git-lfs"
  GIT_LFS_TAR="git-linux-amd64-v${GIT_LFS_VER}.tar.gz"
  GIT_LFS_URL="https://github.com/git-lfs/git-lfs/releases/download/v${GIT_LFS_VER}/${GIT_LFS_TAR}"
  GIT_LFS_INSTALL="1"

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
      fi
    fi
  else
    echo "wget not found, cannot download git lfs"
  fi
 
  if [ $GIT_LFS_INSTALL == 0 ]; then
    echo "install of git lfs set to true"
    download_and_extract $SCRIPTPATH/faaltu/$GIT_LFS_DIR $SCRIPTPATH/faaltu/$GIT_LFS_DIR $GIT_LFS_TAR $GIT_LFS_URL $GIT_LFS_MD5
    if [ -f $SCRIPTPATH/faaltu/$GIT_LFS_DIR/install.sh ]; then
      PREFIX=$HOME $SCRIPTPATH/faaltu/$GIT_LFS_DIR/install.sh
      git -C $SCRIPTPATH lfs install 
    else
      echo "$SCRIPTPATH/faaltu/$GIT_LFS_DIR/install.sh not found"
      echo "git lfs install unsuccessful"
    fi
  fi

