" don't bother with vi compatibility
set nocompatible

" enable syntax highlighting
syntax enable

" --- Configure Vundle ---
filetype on " without this vim emits a zero exit status, later, because of :ft off
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

" install Vundle bundles
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
  source ~/.vimrc.bundles.local
endif

call vundle#end()

" --- Filetype Changes ---
" ensure ftdetect et al work by including this after the Vundle stuff
filetype plugin indent on
" to try and keep ^M from leaking out around here
set ff=unix
" fdoc is yaml
autocmd BufRead,BufNewFile *.fdoc set filetype=yaml
" md is markdown
autocmd BufRead,BufNewFile *.md set filetype=markdown
" some things to keep latex pretty
autocmd Filetype tex setlocal spell spelllang=en_us textwidth=79 formatoptions+=t

" --- Extra Commands ---
command! -bang W try | wq | catch /more file/ | wn | endt
command! -bang -nargs=* -complete=file TSlime call Send_to_Tmux(<q-args>."\n")

" --- Vim Behavior ---
set autoindent
set autoread                 " reload files when changed on disk, i.e. via `git checkout`
set backspace=2              " Fix broken backspace in some setups
set backupcopy=yes           " see :help crontab
set clipboard=unnamed        " yank and paste with the system clipboard
set directory-=.             " don't store swapfiles in the current directory
set encoding=utf-8
set expandtab                " expand tabs to spaces
set ignorecase               " case-insensitive search
set incsearch                " search as you type
set laststatus=2             " always show statusline
set list                     " show trailing whitespace
set listchars=tab:▸\ ,trail:▫
set number                   " show line numbers
set hlsearch                 " highlight search
set ruler                    " show where you are
set scrolloff=3              " show context above/below cursorline
set nocursorline             " don't highlight current line
set shiftwidth=2             " normal mode indentation commands use 2 spaces
set showcmd
set smartcase                " case-sensitive search if any caps
set softtabstop=2            " insert mode tab and backspace use 2 spaces
set tabstop=8                " actual tabs occupy 8 characters
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmode=longest,list,full
set wildmenu                 " show a navigable menu for tab completion

" --- keyboard shortcuts ---
let mapleader = ','
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <leader>l :Align
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
nmap <leader>a :Ag<space>
nmap <leader>b :CtrlPBuffer<CR>
nmap <leader>d :NERDTreeToggle<CR>
nmap <leader>f :NERDTreeFind<CR>
nmap <leader>s :TSlime<space>
nmap <leader>t :CtrlP<CR>
nmap <leader>T :CtrlPClearCache<CR>:CtrlP<CR>
nmap <leader>] :TagbarToggle<CR>
nmap <leader><space> :call whitespace#strip_trailing()<CR>
nmap <leader>g :GitGutterToggle<CR>
" unhighlight everything
nmap <leader>h :let @/ = ""<CR>
" don't copy the contents of an overwritten selection.
vnoremap p "_dP
" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %
inoremap jj <ESC>
" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

" --- Plugin Settings ---
let g:ctrlp_match_window = 'order:ttb,max:20'
let g:NERDSpaceDelims=1
let g:gitgutter_enabled = 0
if executable('ag')
  " Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
  let g:ackprg = 'ag --nogroup --column'
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" Fix Cursor in TMUX
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Disambiguate ,a & ,t from the Align plugin, making them fast again.
function! s:RemoveConflictingAlignMaps()
  if exists("g:loaded_AlignMapsPlugin")
    AlignMapsClean
  endif
endfunction
command! -nargs=0 RemoveConflictingAlignMaps call s:RemoveConflictingAlignMaps()
silent! autocmd VimEnter * RemoveConflictingAlignMaps

" gui settings
colorscheme slate

if &diff
 " extra settings to make things better to see
endif

source ~/.vimrc.local
