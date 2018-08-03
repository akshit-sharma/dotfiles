# /bin/bash

NEED_VIM_PLUGIN_INSTALL=1
NEED_BASH_REFRESH=0
NEED_PROFILE_REFRESH=0

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
  NEED_PROFILE_REFRESH=1
else
  NEED_PROFILE_REFRESH=0
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
    cp $HOME/$dir/$filename $SCRIPTPATH/$filename   # usefull to add new files in the script
  fi                                                   # instead of manually moving/copying
  if [ -f "$HOME/$dir/$filename" ] && [ ! -L "$HOME/$dir/$filename" ]; then
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

if [ -f $HOME/.vimrc ] && [ ! -L "$HOME/.vimrc" ]; then
  mv $HOME/.vimrc $HOME/.vimrc.bk       # backup existing .vimrc
fi
if [ ! -L "$HOME/.vimrc" ]; then
  ln -sT $SCRIPTPATH/.vimrc $HOME/.vimrc
fi

if [ ! -L "$HOME/.my_profile" ]; then
  ln -sT $SCRIPTPATH/.my_profile $HOME/.my_profile
  if [ ! -f "$HOME/.my_vars" ]; then
    touch $HOME/.my_vars
  fi
fi

if [ ! -L "$HOME/.my_bashrc" ]; then
  ln -sT $SCRIPTPATH/.my_bashrc $HOME/.my_bashrc
fi

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

update_bashrc "source ~/.my_profile" $NEED_PROFILE_REFRESH "already calling ~/.my_profile" 
NEED_PROFILE_REFRESH=$REFRESH


  echo "bef val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_PROFILE_REFRESH"

if [[ NEED_BASH_REFRESH -ne 0 ]]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing bashrc"
  fi
  #source ~/.bashrc # cannot source bashrc from script
  source ~/.my_profile "$SCRIPTPATH"
  NEED_PROFILE_REFRESH=0
fi

echo "after bash of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_PROFILE_REFRESH"

if [[ NEED_PROFILE_REFRESH -ne 0 ]]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "sourcing my_profile $SCRIPTPATH"
  fi
  source ~/.my_profile "$SCRIPTPATH"
fi

echo "after prof val of bash and prof refresh are $NEED_BASH_REFRESH and $NEED_PROFILE_REFRESH"

if [[ NEED_VIM_PLUGIN_INSTALL -ne 0 ]]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "running vim +PluginInstall...."
  fi
  vim +PluginInstall +qall
fi

