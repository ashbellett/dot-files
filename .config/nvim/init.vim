" ~/.config/nvim/init.vim
" Ash Bellett

" Plugins
call plug#begin('~/.local/share/nvim/plugged')
  Plug 'jiangmiao/auto-pairs'
  Plug 'vim-python/python-syntax'
call plug#end()

let g:python_highlight_all = 1

" Visuals
set number
set ruler

" Features
syntax on
set magic
filetype plugin on
filetype indent on

" Tabs
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab

" Backspaces
set backspace=eol,start,indent

" Brackets
set showmatch

" Mouse
set mouse=a

" Search
set incsearch
set ignorecase
set smartcase
set hlsearch

" Hide tildes
highlight EndOfBuffer ctermfg=0 ctermbg=0

" Colours
highlight Comment ctermbg=0 ctermfg=7
highlight String ctermbg=0 ctermfg=6
highlight Character ctermbg=0 ctermfg=3
highlight Number ctermbg=0 ctermfg=1
highlight Boolean ctermbg=0 ctermfg=1
highlight Float ctermbg=0 ctermfg=1
highlight Function ctermbg=0 ctermfg=4
highlight Statement ctermbg=0 ctermfg=5
highlight Operator ctermbg=0 ctermfg=5
highlight Type ctermbg=0 ctermfg=5
highlight PreProc ctermbg=0 ctermfg=5
highlight Keyword ctermbg=0 ctermfg=6
highlight LineNr ctermbg=0 ctermfg=7

