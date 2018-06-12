# /bin/bash

# plugin manager for vim
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

NEED_PROFILE_REFRESH=0
NEED_BASH_REFRESH=0

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ ! -L "$HOME/.vimrc" ]; then
  ln -sT $SCRIPTPATH/.vimrc $HOME/.vimrc
fi

if [ ! -L "$HOME/.my_profile" ]; then
  ln -sT $SCRIPTPATH/.my_profile $HOME/.my_profile
  if [ ! -f "$HOME/.my_vars" ]; then
    touch $HOME/.my_vars
  fi
fi

if [ ! -L "$HOME/.tmux.conf" ]; then
  ln -sT $SCRIPTPATH/.tmux.conf $HOME/.tmux.conf
fi

mkdir -p ~/.vim/tags

# all symlink done (configuration structure established)

if cat ~/.bashrc | grep -xqFe "source ~/.my_profile" 
then
  echo "~/.bashrc already calling ~/.my_profile"
else
  echo "" >> ~/.bashrc
  echo "source ~/.my_profile" >> ~/.bashrc
  echo "" >> ~/.bashrc
  NEED_PROFILE_REFRESH=1
fi

if cat ~/.bashrc | grep -xqFe "#force_color_prompt=yes"
then
  sed -i 's/#force_color_prompt/force_color_prompt/g' ~/.bashrc
  NEED_BASH_REFRESH=1
else
  echo "force_color_prompt already set"
fi

if [ "$NEED_BASH_REFRESH" ] then
  source ~/.bashrc
  NEED_PROFILE_REFRESH=0
fi

if [ "$NEED_PROFILE_REFRESH" ] 
then
  source ~/.my_profile
fi


vim +PluginInstall +qall

