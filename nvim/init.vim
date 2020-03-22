
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

colorscheme slate

for f in split(glob('~/.config/nvim/config/*.vim'), '\n')
  exe 'source' f
endfor

