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
" SQL templating
autocmd BufRead,BufNewFile *.swigql set filetype=sql
autocmd BufRead,BufNewFile *.sql.jinja set filetype=sql
" JIRA ticket formatting
autocmd BufRead,BufNewFile *.cw set filetype=confluencewiki
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
set ignorecase               " case-insensitive search
set incsearch                " search as you type
set laststatus=2             " always show statusline
set list                     " show trailing whitespace
set listchars=tab:▸\ ,trail:▫
set number                   " show line numbers
set hlsearch                 " highlight search
set ruler                    " show where you are
set scrolloff=5              " show context above/below cursorline
set nocursorline             " don't highlight current line
set showcmd
set smartcase                " case-sensitive search if any caps
set tabstop=4                " actual tabs occupy 4 characters
set shiftwidth=4             " prevents me from using multiple tabs at a time
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmode=longest,list,full
set wildmenu                 " show a navigable menu for tab completion
set vb                       " disable bells

" --- keyboard shortcuts ---
let mapleader = ','
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
map <leader>l :Align
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>
nnoremap <leader>a :Ag<space>
nnoremap <leader>b :CtrlPBuffer<CR>
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
nnoremap <leader>t :CtrlP<CR>
nnoremap <leader>k :Kwbd<CR>
nnoremap <leader>T :CtrlPClearCache<CR>:CtrlP<CR>
nnoremap <leader>] :TagbarToggle<CR>
nnoremap <leader><space> :call whitespace#strip_trailing()<CR>
nnoremap <leader>g :GitGutterToggle<CR>
nnoremap <leader>j %!python -mjson.tool<CR>
nnoremap <leader>E :ALEPreviousWrap<CR>
nnoremap <leader>e :ALENextWrap<CR>
" unhighlight everything
nnoremap <leader>h :let @/ = ""<CR>
" don't copy the contents of an overwritten selection.
vnoremap p "_dP
" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %
inoremap jj <ESC>
" automatically rebalance windows on vim resize
autocmd VimResized * :wincmd =

command! -bang W try | wq | catch /more file/ | wn | endt
command! -bang Q q

" --- Plugin Settings ---
let g:ctrlp_match_window = 'order:ttb,max:20'
let g:NERDSpaceDelims=1
let NERDTreeIgnore = ['\.pyc$']
let g:gitgutter_enabled = 0
let g:jsx_ext_required = 0

if executable('ag')
  " Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
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
colorscheme Tomorrow-Night-Eighties
set guioptions=gm

highlight Pmenu ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#000000

source ~/.vimrc.local
