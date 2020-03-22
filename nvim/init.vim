
call plug#begin('~/.config/nvim/plugged')

Plug 'neoclide/coc.nvim', {'branch' : 'release'}

call plug#end()

" if hidden is not set, TextEdit might fail
set hidden

" Some servers have issues with backup files,
set nobackup
set nowritebackup

" Better display for messages
set cmdheight=2

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" always show signcolumns
set signcolumn=yes

" Spaces & Tabs
set tabstop=2       " number of visual spaces per TAB
set softtabstop=2   " number of spaces in tab when editing
set shiftwidth=2    " number of spaces to use for autoindent
set expandtab       " tabs are space
set autoindent
set copyindent      " copy indent from the previous line
" }}} Spaces & Tabs

colorscheme slate

for f in split(glob('~/.config/nvim/config/*.vim'), '\n')
  exe 'source' f
endfor

