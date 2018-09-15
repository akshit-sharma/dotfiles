# disclamer
This repository is highly unstable. It contains my personal configuration for the system and will be changed rapidly without concern for cross-platform compatibility. The script will have a few cases to handle backword script version compatibility and these will be modified as they appear.

Feel free to modify the repository and make it your own.

# quick install

```bash
DOTFILES_SCRIPT_DIR=${HOME}/dotfiles; curl -fsSl https://raw.githubusercontent.com/akshit-sharma/dotfiles/master/download_and_install.sh | bash
```
or 
set DOTFILES_SCRIPT_DIR enviroment variable
```bash
DOTFILES_SCRIPT_DIR=${HOME}/dotfiles
```
then run the script to install in some other folder
```bash
curl -fsSl https://raw.githubusercontent.com/akshit-sharma/dotfiles/master/download_and_install.sh | bash
```

# normal install 
```bash
git clone https://github.com/akshit-sharma/dotfiles.git
```
or 
```bash
git clone git@github.com:akshit-sharma/dotfiles.git
```

Note: script will not be able to push automatically, if you have configured with https. It will ask for password everytime


# cheatsheet for vim

> Simple cheatsheet for my personal ~/.vimrc file

## normal mode
```bash
C-n            # open NERDTree
```

## function key shortcuts
```bash
F4             # switch between header/source cpp fike

F7             # make
S-F7           # make clean

F9             # toggle quickfix window

C-F11          # make ctags in root of current folder
S-F11          # make ctags inside .git of current folder 
```

## alias shortcuts
```bash
<Leader> for vim is \ (backslash)
<Leader>S        # toggle scrollbind

<Leader>d        # goto definition (F12) ctags should be present

<Leader>th       # goto first tab
<Leader>tk       # goto next tab
<Leader>tj       # goto prev tab
<Leader>tl       # goto last tab
<Leader>tt       # tabedit (open file in new tab)
<leader>tm num   # move current tab to num pos
<Leader>td       # close current tab
<Leader>tn       # open new tab
<Leader>ts       # tab split

<Leader>Y        # toggle syntastic checking

#d             # for #define
#i             # for #include
#b             # for starting of block comment
#e             # for ending of block comment
#l             # for line separation
```


## visual mode
```bash
:gc            # toggle comments
```

## easymotion
```bash
<Leader> for easy motion is f

<Leader>s{char}{char}   # to move to {char}{char}
<Leader>L               # to move to line

EasyMotion <Plug> table                       *easymotion-plug-table*

    <Plug> Mapping Table | Default
    ---------------------|----------------------------------------------
    <Plug>(easymotion-f) | <Leader>f{char}
    <Plug>(easymotion-F) | <Leader>F{char}
    <Plug>(easymotion-t) | <Leader>t{char}
    <Plug>(easymotion-T) | <Leader>T{char}
    <Plug>(easymotion-w) | <Leader>w
    <Plug>(easymotion-W) | <Leader>W
    <Plug>(easymotion-b) | <Leader>b
    <Plug>(easymotion-B) | <Leader>B
    <Plug>(easymotion-e) | <Leader>e
    <Plug>(easymotion-E) | <Leader>E
    <Plug>(easymotion-ge)| <Leader>ge
    <Plug>(easymotion-gE)| <Leader>gE
    <Plug>(easymotion-j) | <Leader>j
    <Plug>(easymotion-k) | <Leader>k
    <Plug>(easymotion-n) | <Leader>n
    <Plug>(easymotion-N) | <Leader>N
    <Plug>(easymotion-s) | <Leader>s

```

## gutentags
# Keymaps

| keymap | desc |
|--------|------|
| `<leader>gs` | Find symbol (reference) under cursor |
| `<leader>gg` | Find symbol definition under cursor |
| `<leader>gd` | Functions called by this function |
| `<leader>gc` | Functions calling this function |
| `<leader>gt` | Find text string under cursor |
| `<leader>ge` | Find egrep pattern under cursor |
| `<leader>gf` | Find file name under cursor |
| `<leader>gi` | Find files #including the file name under cursor |
| `<leader>ga` | Find places where current symbol is assigned |


