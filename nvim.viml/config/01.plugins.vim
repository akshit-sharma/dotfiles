
if (empty(glob('~/.config/nvim/autoload/plug.vim')))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" src: https://gist.github.com/kkoomen/68319b08ab843ce67cf7b282b0b2fd24
function! OnVimEnter() abort
  " Run PlugUpdate every week automatically when entering vim.
  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    PlugInstall --sync | source $MYVIMRC
  endif
  if exists('g:plug_home')
    let l:filename = printf('%s/.plug_last_update', g:plug_home)
    if filereadable(l:filename) == 0
      call writefile([], l:filename)
    endif

    let l:this_week = strftime('%Y-%V')
    let l:contents = readfile(l:filename)
    if index(l:contents, l:this_week) < 0
      call execute('PlugUpdate')
      call writefile([l:this_week], l:filename, 'a')
    endif
  endif
endfunction

autocmd VimEnter * call OnVimEnter()

call plug#begin('~/.config/nvim/plugged')

Plug 'navarasu/onedark.nvim'
Plug 'doums/darcula'
Plug 'neoclide/coc.nvim', {'branch' : 'release'}
Plug 'tpope/vim-fugitive'
Plug 'nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'}
Plug 'romgrk/nvim-treesitter-context'
Plug 'preservim/tagbar', {'on': 'TagbarToggle'}
Plug 'p00f/nvim-ts-rainbow'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sbdchd/neoformat'
Plug 'github/copilot.vim', {'branch': 'release', 'do': 'Copilot setup'}
Plug 'lervag/vimtex'
"Plug 'numToStr/Comment.nvim'
"Plug 'tomtom/tcomment_vim'
Plug 'luochen1990/rainbow'
Plug 'liuchengxu/vista.vim'
Plug 'wbthomason/packer.nvim'
Plug 'neovim/nvim-lspconfig'
"Plug 'nvim-lua/plenary.nvim'
"Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }

call plug#end()

let g:rainbow_active = 1
