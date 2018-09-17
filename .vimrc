set nocompatible  		" be iMproved, required
filetype off 	    		" required

set background=dark

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
"Plugin 'OmniCppComplete'

" jump to words
Plugin 'easymotion/vim-easymotion'

" show git modifications
Plugin 'airblade/vim-gitgutter'

" Rainbow brackets
Plugin 'luochen1990/rainbow'

" Async run commands in shell
Plugin 'skywind3000/asyncrun.vim'

" vim-cmake-syntax
Plugin 'pboettch/vim-cmake-syntax'

" GLFW syntax Highlighting
Plugin 'bfrg/vim-glfw-syntax'

" vimwiki
Plugin 'vimwiki/vimwiki'

" fugitive for git wrapper
Plugin 'tpope/vim-fugitive'
" for vim version < 7.2
Plugin 'tpope/vim-git'

" " syntastic for syntax checking
" Plugin 'vim-syntastic/syntastic'

" cpp autocomplete
Plugin 'Valloric/YouCompleteMe'

" YCM-Generator
Plugin 'rdnetto/YCM-Generator'

" latex plugin for vim
Plugin 'lervag/vimtex'

" Gutentags 
Plugin 'ludovicchabant/vim-gutentags'
Plugin 'skywind3000/gutentags_plus'

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

" highlighting with vulkan1.0.vim
autocmd FileType cpp,c source ~/.vim/syntax/vulkan1.0.vim

" highlighting with opengl.vim
"autocmd FileType cpp,c source ~/.vim/syntax/opengl.vim

"autocmd FileType *.py set shiftwidth=2|set softtabstop=2|set tabstop=2|set expandtab

" for vim wiki plugin
syntax on

function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

" use indentation of previous line
set autoindent

" use intelligent indentation for C
set smartindent

" configure tabwidth and insert spaces instead of tabs
set tabstop=2         " tab width is 2 spaces
set shiftwidth=2      " indent also with 2 spaces
set expandtab         " expand tabs to spaces
set softtabstop=2

" warp lines at 160 chars, 80 is somewhat antiquated with nowadays displays
set textwidth=160

" turn line numbers on
set number

" highlight matching braces
set showmatch

" NERDTree linked to ctrl-n
nnoremap <C-n> :NERDTree<CR>

" map ctrl-b to ctrl-w (tmux uses ctrl-b)
map <C-b> <C-w>

" can toggle comment with ctrl-t
":nnoremap <C-x> :V<CR>:gc<CR>

" optional features for octol/vim-cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_concepts_highlight = 1
let g:cpp_no_function_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1

" vim have issue with flagging braces as errors (workaround)
let c_no_curly_error=1

" for cpp_gcc_7
set tags+=~/.vim/tags/cpp_gcc_7

" for working project
set tags+=.git/tags;./tags;

" build tags of your own project with ctrl-F11
map <C-F11> :!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --exclude=.git .<CR> 
map <S-F11> :!cd .git && ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q --exclude=.git .. && cd ..<CR>  

" " OmniCppComplete
" let OmniCpp_NamespaceSearch = 1
" let OmniCpp_GlobalScopeSearch = 1
" let OmniCpp_ShowAccess = 1
" let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
" let OmniCpp_MayCompleteDot = 1      " autocomplete after .
" let OmniCpp_MayCompleteArrow = 1    " autocomplete after ->
" let OmniCpp_MaycompleteScope = 1    " autocomplete after ::
" let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"] " check if I need this
" " automatically open and close the popup menu / preview window
" au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
" set completeopt=menuone,menu,longest,preview
 
" YCM (YouCompleteMe)
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_always_populate_location_list = 1 "default 0
let g:ycm_open_loclist_on_ycm_diags = 1 "default 1

let g:ycm_global_ycm_extra_conf = '$DOTFILES_SCRIPT_PARENT/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0 " 1 (for now, asks everytime instead of just once )

let g:ycm_key_invoke_completion = '<C-space>'

" switch between header/source with F4
map <F4> :e %:p:s,.h$,.X123X,:s,:.cpp$,.h,:s,.X123X$,.cpp,<CR>

" build using makeprg with <F7>
map <F7> :make<CR>

" build using makeprg with <S-F7>
map <S-F7> :make clean<CR>

" toggle quickfix window with <F9>
noremap <F9> :call asyncrun#quickfix_toggle(8)<CR>

map <Leader>a :call asyncrun#quickfix_toggle(8)<CR>
map <Leader><Space>d :DiffSaved<CR>

" for ctags jumps
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <Leader><C-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
map <Leader><S-C-]> :sp <CR>:exec("tag ".expand("<cword>"))<CR>

" Configuration for easymotion
let g:EasyMotion_leader_key='f'
" <Leader>f{char} to move to {char}
map <Plug>(easymotion-prefix)f <Plug>(easymotion-bd-f)
map <Plug>(easymotion-prefix)f <Plug>(easymotion-overwin-f)
" s{char}{char} to move to {char}{char}
nmap <Plug>(easymotion-prefix)s <Plug>(easymotion-overwin-f2)
" Move to line
map <Plug>(easymotion-prefix)L <Plug>(easymotion-bd-jk)
nmap <Plug>(easymotion-prefix)L <Plug>(easymotion-overwin-line)
" Move to word
map <Plug>(easymotion-prefix)w <Plug>(easymotion-bd-w)
nmap <Plug>(easymotion-prefix)w <Plug>(easymotion-overwin-w)

" toggle scrollbind use `:set scb?` to see current state
map <Leader>S :set scb!<CR>

" 0 if you want to enable it later via :RainbowToggle
let g:rainbow_active = 1

let g:rainbow_conf = {
  \  'separately': {
  \       'cmake': 0,
  \    }
  \ }

" Always show statusline
set laststatus=2
let g:lightline = {
  \   'active': {
  \     'left': [['mode', 'paste'], [ 'readonly', 'filename', 'modified', 'gitbranch' ]],
  \     'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding', 'filetype']]
  \   },
  \   'component_function' : {
  \     'gitbranch': 'fugitive#head'
  \   }
  \ }

" " for syntastic for syntax checking
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0


" nice abbreviations
ab #d #define
ab #i #include

" abbreviations to draw comments
ab #b /*******************************************************************************
ab #e *******************************************************************************/
ab #l /******************************************************************************/

"highlight TooMuchChars ctermbg=155 guibg=#afff5f
highlight TooMuchChars cterm=underline

" Define autocmd for some highlighting *before* the colorscheme is loaded
augroup VimrcColors
au!
  autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen   guibg=#444444
  autocmd ColorScheme * highlight Tab             ctermbg=darkblue    guibg=darkblue
augroup END

au BufWinEnter * let w:m1=matchadd('TooMuchChars', '\%>80v.\+', -1)

" for tab navigation
nnoremap <Leader>th :tabfirst<CR>
nnoremap <Leader>tk :tabnext<CR>
nnoremap <Leader>tj :tabprev<CR>
nnoremap <Leader>tl :tablast<CR>
nnoremap <Leader>tt :tabedit<Space>
nnoremap <Leader>tn :tabnext<Space>
nnoremap <Leader>tm :tabm<Space>
nnoremap <Leader>td :tabclose<CR>
nnoremap <Leader>tn :tabnew<CR>
nnoremap <Leader>ts :tab<Space> split<CR>
" for navigation with ctrl modifier
nnoremap <C-S-tab>  :tabprevious<CR>
nnoremap <C-tab>    :tabnext<CR>
"nnoremap <C-t>      :tabnew<CR>             Ctrl-t used in ctags
inoremap <C-S-tab>  <Esc>:tabprevious<CR>i
inoremap <C-tab>    <Esc>:tabnext<CR>i
"inoremap <C-t>      <Esc>:tabnew<CR>        Ctrl-t used in ctags
" open files always in new tabs
"autocmd VimEnter * tab all
"autocmd BufAdd * exe 'tablast | tabe "' . expand ( "<afile") . '"'


nnoremap <Leader>y :YcmGenerateConfig --compiler $DOTFILES_SCRIPT_PARENT/faaltu/clang+llvm/bin/clang .<CR>
inoremap <Leader>y <Esc>:YcmGenerateConfig --compiler $DOTFILES_SCRIPT_PARENT/faaltu/clang+llvm/bin/clang .<CR>
nnoremap <Leader>Y :CCGenerateConfig --compiler $DOTFILES_SCRIPT_PARENT/faaltu/clang+llvm/bin/clang .<CR>
inoremap <Leader>Y <Esc>:CCGenerateConfig --compiler $DOTFILES_SCRIPT_PARENT/faaltu/clang+llvm/bin/clang .<CR>

" nnoremap <Leader>Y :SyntasticToggleMode<CR>
" inoremap <Leader>Y :SyntasticToggleMode<CR>

" mouse does not select line numbers # default is c
set mouse=a

" open NERDTree by default
"autocmd VimEnter * NERDTree
"autocmd BufEnter * NERDTreeMirror
"autocmd VimEnter * wincmd 

" enable gtags module
"let g:gutentags_modules = ['ctags', 'gtags_cscope']
let g:gutentags_modules = ['ctags']
let g:gutentags_project_root = ['.git']
let g:gutentags_cache_dir = expand('~/.cache/tags')
let g:gutentags_auto_add_gtags_cscope = 0
let g:gutentags_plus_nomap = 1
noremap <leader>gs :GscopeFind s <C-R><C-W><cr>
noremap <leader>gg :GscopeFind g <C-R><C-W><cr>
noremap <leader>gc :GscopeFind c <C-R><C-W><cr>
noremap <leader>gt :GscopeFind t <C-R><C-W><cr>
noremap <leader>ge :GscopeFind e <C-R><C-W><cr>
noremap <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
noremap <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
noremap <leader>gd :GscopeFind d <C-R><C-W><cr>
noremap <leader>ga :GscopeFind a <C-R><C-W><cr>


" alias for some fn commands
" make 
map <Leader><Leader>m <F7>
" make clean
map <Leader><Leader>M <S-F7>
" ctags
map <Leader><Leader>c <C-F11>
" ctags in ./.git/tags
map <Leader><Leader>C <S-F11>
" switch between header/source file
map <Leader><Leader>s <F4>
" goto definition
map <Leader><Leader>d <F12>


