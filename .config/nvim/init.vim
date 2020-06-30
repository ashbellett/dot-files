" ~/.config/nvim/init.vim
" Ash Bellett

" Plugins:
call plug#begin('~/.local/share/nvim/plugged')
  Plug 'Shougo/deoplete.nvim'
  Plug 'deoplete-plugins/deoplete-jedi'
  Plug 'preservim/nerdtree'
  Plug 'Xuyuanp/nerdtree-git-plugin'
  Plug 'vim-airline/vim-airline'
  Plug 'jiangmiao/auto-pairs'
call plug#end()

" Visuals:
set number
set ruler

" Features:
syntax on
set magic
filetype plugin on
filetype indent on

" Tabs:
set tabstop=4
set shiftwidth=4
set expandtab
set smarttab

" Backspaces:
set backspace=eol,start,indent

" Brackets:
set showmatch

" Mouse:
set mouse=a

" Search:
set incsearch
set ignorecase
set smartcase
set hlsearch

" Hide tildes:
highlight EndOfBuffer ctermfg=0 ctermbg=0

" Colours:
highlight Comment ctermbg=7 ctermfg=0
highlight Constant ctermbg=1 ctermfg=0
highlight String ctermbg=3 ctermfg=0
highlight Character ctermbg=3 ctermfg=0
highlight Number ctermbg=1 ctermfg=0
highlight Boolean ctermbg=1 ctermfg=0
highlight Float ctermbg=1 ctermfg=0
highlight Identifier ctermbg=NONE ctermfg=0
highlight Function ctermbg=4 ctermfg=0
highlight Statement ctermbg=5 ctermfg=0
highlight Operator ctermbg=2 ctermfg=0
highlight Type ctermbg=5 ctermfg=0
highlight PreProc ctermbg=6 ctermfg=0
highlight Keyword ctermbg=6 ctermfg=0
highlight LineNr ctermbg=7 ctermfg=0
