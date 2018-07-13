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
    mv "$HOME/.config/$filename" "$HOME/.config/$filename.bk"
  fi
  if [ ! -L "$HOME/.config/$filename" ]; then
    if [[ DEBUG_SCRIPT -ne 0 ]]; then
      echo "linking $SCRIPTPATH/$filename to $HOME/.config/$filename"
    fi
    ln -sT $SCRIPTPATH/$filename $HOME/.config/$filename
  fi
}


# if kde plasma get my shortcuts
if [ "$DESKTOP_SESSION" = "plasma" ]; then
  if [[ DEBUG_SCRIPT -ne 0 ]]; then
     echo "plasma (kde) detected"
  fi
  PLASMASHELL_VERSION=`eval plasmashell --version | sed -nr 's/plasmashell ([0-9][0-9]*\.*)/\1/p'`
  PLASMASHELL_MAJOR=`plasmashell --version | sed -rn 's/plasmashell ([0-9])\.[0-9].*/\1/p'`
  if [ $PLASMASHELL_MAJOR -eq 5 ]; then
    home_config_symlink kglobalshortcutsrc.kksrc
    home_config_symlink khotkeysrc
    home_config_symlink quicktile.cfg
    home_config_symlink Xmodmap
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

if [ ! -L "$HOME/.vimrc" ]; then
  ln -sT $SCRIPTPATH/.vimrc $HOME/.vimrc
fi

if [ ! -L "$HOME/.profile" ]; then
  ln -sT $SCRIPTPATH/.profile $HOME/.profile
fi

if [ ! -L "$HOME/.my_profile" ]; then
  ln -sT $SCRIPTPATH/.my_profile $HOME/.my_profile
  if [ ! -f "$HOME/.my_vars" ]; then
    touch $HOME/.my_vars
  fi
fi

#if [ ! -L "$HOME/.tmux.conf" ]; then
#  ln -sT $SCRIPTPATH/.tmux.conf $HOME/.tmux.conf
#fi

mkdir -p ~/.vim/tags

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

