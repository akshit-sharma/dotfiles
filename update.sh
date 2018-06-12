# /bin/bash

if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ ! -L "$HOME/.vimrc" ]; then
  ln -sT $SCRIPTPATH/.vimrc $HOME/.vimrc
fi

if [ ! -L "$HOME/.profile" ]; then
  ln -sT $SCRIPTPATH/.profile $HOME/.profile
  if [ ! -f "$HOME/.my_vars" ]; then
    touch $HOME/.my_vars
  fi
fi 

vim +PluginInstall +qall

