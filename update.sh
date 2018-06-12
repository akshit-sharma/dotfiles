# /bin/bash

# plugin manager for vim
if [ ! -d "$HOME/.vim/bundle/Vundle.vim" ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
fi

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

mkdir -p ~/.vim/tags

# all symlink done (configuration structure established)

if cat ~/.bashrc | grep -xqFe "source ~/.my_profile" 
then
  echo "~/.bashrc already calling ~/.my_profile"
else
  echo "" >> ~/.bashrc
  echo "source ~/.my_profile" >> ~/.bashrc
  echo "" >> ~/.bashrc

  # call the ~/my_profile (it was not in ~/.bashrc in this session
  source ~/.my_profile  

fi

vim +PluginInstall +qall

