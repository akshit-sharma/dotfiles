set nocompatible  		" be iMproved, required
filetype off 	    		" required

" set the runtime path to include Vundle and initialize
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin("~/some/path/here")

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The NERD tree
Plugin 'scrooloose/nerdtree'

" cpp enhanced highlight
Plugin 'octol/vim-cpp-enhanced-highlight'

" fuzzy file and buffer finder
Plugin 'ctrlpvim/ctrlp.vim'

" make status bar prettier
Plugin 'itchyny/lightline.vim'

" syntax-aware plugin for easy commenting
Plugin 'tomtom/tcomment_vim'

" cpp autocomplete
Plugin 'OmniCppComplete'

" jump to words
Plugin 'easymotion/vim-easymotion'

" show git modifications
Plugin 'airblade/vim-gitgutter'

" Rainbow brackets
Plugin 'luochen1990/rainbow'

" All of your Plugins must be added before the following line
call vundle#end() 		" required
filetype plugin indent on 	" required
" To ignore plugin indent changes, instead use:
" filetype plugin on
"
" Brief help
" :PluginList       - list configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal for unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details for wifi for FAQ
" Put your non-Plugin stuff after this line

" use indentation of previous line
set autoindent

" use intelligent indentation for C
set smartindent

" configure tabwidth and insert spaces instead of tabs
set tabstop=2         " tab width is 4 spaces
set shiftwidth=2      " indent also with 4 spaces
set expandtab         " expand tabs to spaces

" warp lines at 160 chars, 80 is somewhat antiquated with nowadays displays
set textwidth=160

" turn line numbers on
set number

" highlight matching braces
set showmatch

" NERDTree linked to ctrl-n
:nnoremap <C-n> :NERDTree<CR>

" map ctrl-b to ctrl-w (tmux uses ctrl-b)
:map <C-b> <C-w>

" can toggle comment with ctrl-t
":nnoremap <C-x> :V<CR>:gc<CR>

" optional features for octol/vim-cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1

" vim have issue with flagging braces as errors (workaround)
let c_no_curly_error=1

" for cpp_gcc_7
set tags+=~/.vim/tags/cpp_gcc_7

" build tags of your own project with ctrl-F11
map <C-F12> :!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" OmniCppComplete
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1      " autocomplete after .
let OmniCpp_MayCompleteArrow = 1    " autocomplete after ->
let OmniCpp_MaycompleteScope = 1    " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"] " check if I need this
" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview

" switch between header/source with F4
map <F4> :e %:p:s,.h$,.X123X,:s,:.cpp$,.h,:s,.X123X$,.cpp,<CR>

" build using makeprg with <F7>
map <F7> :make<CR>

" build using makeprg with <S-F7>
map <S-F7> :make clean all<CR>

" goto definition with <F12>
map <F12> <C-]>

" Configuration for easymotion
let g:EasyMotion_leader_key='\'
" <Leader>f{char} to move to {char}
map <Leader>f <Plug>(easymotion-bd-f)
map <Leader>f <Plug>(easymotion-overwin-f)
" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)
" Move to line
map <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)
" Move to word
map <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

" 0 if you want to enable it later via :RainbowToggle
let g:rainbow_active = 1

" Always show statusline
set laststatus=2
let g:lightline = {
  \   'active': {
  \     'left': [['mode', 'paste'], ['readonly', 'filename', 'modified']],
  \     'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding', 'filetype']]
  \   }
  \ }

" nice abbreviations
ab #d #define
ab #i #include

" abbreviations to draw comments
ab #b /*******************************************************************************
ab #e *******************************************************************************/
ab #l /******************************************************************************/

"set colorcolumn=81
"highlight ColorColumn ctermbg=lightgrey guibg=lightgrey

au BufWinEnter * let w:m1=matchadd('ErrorMsg', '\%>80v.\+', -1)


" open NERDTree by default
autocmd VimEnter * NERDTree
autocmd BufEnter * NERDTreeMirror
autocmd VimEnter * wincmd w
