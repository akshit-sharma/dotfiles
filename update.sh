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
    echo "value is $SCRIPTPATH/$filename"
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


# function for creating symlink to files in $HOME/.config
function home_config_symlink {
  filename="$1"
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "value is $SCRIPTPATH/$filename"
  fi
  if [ ! -f $SCRIPTPATH/$filename ]; then              # pretty much use less after getting files
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "copying $HOME/.config/$filename to $SCRIPTPATH/$filename"
    fi
    cp $HOME/.config/$filename $SCRIPTPATH/$filename   # usefull to add new files in the script
  fi                                                   # instead of manually moving/copying
  if [ -f "$HOME/.config/$filename" ]; then
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "moving $HOME/.config/$filename to $HOME/.config/$filename.bk"
    fi
    if [ ! -f "$HOME/.config/$filename.bk" ]; then
      mv "$HOME/.config/$filename" "$HOME/.config/$filename.bk"
    else
      echo "$HOME/.config/$filename.bk already present assuming $filename in $HOME/.config is latest"
    fi
  fi
  if [ ! -L "$HOME/.config/$filename" ]; then
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "linking $SCRIPTPATH/$filename to $HOME/.config/$filename"
    fi
    ln -sT $SCRIPTPATH/$filename $HOME/.config/$filename
  fi
}

# function for creating symlink to files in $HOME/.vim/syntax
function vim_syntax_symlink {
  filename="$1"
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
    echo "value is $SCRIPTPATH/$filename"
  fi
  if [ ! -d $HOME/.vim/syntax ]; then
    mkdir -p $HOME/.vim/syntax
  fi
  if [ ! -f $SCRIPTPATH/$filename ]; then              # pretty much use less after getting files
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "copying $HOME/.vim/syntax/$filename to $SCRIPTPATH/$filename"
    fi
    cp $HOME/.vim/syntax/$filename $SCRIPTPATH/$filename   # usefull to add new files in the script
  fi                                                       # instead of manually moving/copying
  if [ -f "$HOME/.vim/syntax/$filename" ]; then
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "moving $HOME/.vim/syntax/$filename to $HOME/.vim/syntax/$filename.bk"
    fi
    if [ ! -f "$HOME/.vim/syntax/$filename.bk" ]; then
      mv "$HOME/.vim/syntax/$filename" "$HOME/.vim/syntax/$filename.bk"
    else
      echo "$HOME/.vim/syntax/$filename.bk already present assuming $filename in $HOME/.vim/syntax is latest"
    fi
  fi
  if [ ! -L "$HOME/.vim/syntax/$filename" ]; then
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "linking $SCRIPTPATH/$filename to $HOME/.vim/syntax/$filename"
    fi
    ln -sT $SCRIPTPATH/$filename $HOME/.vim/syntax/$filename
  fi
}

# script for adding llvm to environment
home_dir_symlink llvm_scripts .

# manual linking of files for ~/.vim/syntax dir
home_dir_symlink vulkan1.0.vim .vim/syntax

# symlink directory for vimwiki
home_dir_symlink vimwiki .

# if kde plasma get my shortcuts
if [ "$DESKTOP_SESSION" = "plasma" ]; then
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
  
if [ ! -f "$HOME/.my_vars" ]; then
  touch $HOME/.my_vars
fi

# if [ -f $HOME/.vimrc ] && [ ! -L "$HOME/.vimrc" ]; then
#   mv $HOME/.vimrc $HOME/.vimrc.bk       # backup existing .vimrc
# fi
# if [ ! -L "$HOME/.vimrc" ]; then
#   ln -sT $SCRIPTPATH/.vimrc $HOME/.vimrc
# fi
#
# if [ ! -L "$HOME/.my_profile" ]; then
#   ln -sT $SCRIPTPATH/.my_profile $HOME/.my_profile
# fi
#
# if [ ! -L "$HOME/.my_bashrc" ]; then
#   ln -sT $SCRIPTPATH/.my_bashrc $HOME/.my_bashrc
# fi

#if [ ! -L "$HOME/.tmux.conf" ]; then
#  ln -sT $SCRIPTPATH/.tmux.conf $HOME/.tmux.conf
#fi

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
  wget --version > /dev/null
  if [ "$?" == 0 ]; then 
    echo "wget found"
    LLVM_CORRECT_MD5='661fa37f6557d9544ed950d40c05a6fa'
    LLVM_PREBINARY_DIR='clang+llvm-6.0.1-x86_64-linux-gnu-ubuntu-16.04'
    LLVM_PREBINARY_TAR='clang+llvm-6.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz'
    LLVM_PREBINARY_URL='http://releases.llvm.org/6.0.1/clang+llvm-6.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz' 
    if [ ! -d "$SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR" ]; then
      if [ ! -f "$SCRIPTPATH/faaltu/$LLVM_PREBINARY_TAR" ]; then
        echo "downloading $SCRIPTPATH/faaltu/$LLVM_PREBINARY_TAR"
        wget $LLVM_PREBINARY_URL -O $SCRIPTPATH/faaltu/$LLVM_PREBINARY_TAR
      else 
        LLVM_PREBINARY_MD5=`eval md5sum $SCRIPTPATH/faaltu/$LLVM_PREBINARY_TAR | cut -d' ' -f1`
        if [ "$LLVM_CORRECT_MD5" != "$LLVM_PREBINARY_MD5" ]; then
          echo "redownloading LLVM prebinary"
          rm $SCRIPTPATH/faaltu/$LLVM_PREBINARY_TAR
          wget $LLVM_PREBINARY_URL -O $SCRIPTPATH/faaltu/$LLVM_PREBINARY_TAR 
        fi
      fi
      rm -rf $SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR
      tar -xf $SCRIPTPATH/faaltu/$LLVM_PREBINARY_TAR -C $SCRIPTPATH/faaltu/
    else
      echo "$SCRIPTPATH/faaltu/$LLVM_PREBINARY_DIR already exists"
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

fi

