call plug#begin()
 Plug 'dracula/vim'
 Plug 'ryanoasis/vim-devicons'
 Plug 'honza/vim-snippets'
 Plug 'scrooloose/nerdtree'
 Plug 'preservim/nerdcommenter'
 Plug 'mhinz/vim-startify'
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
 Plug 'romgrk/barbar.nvim'
call plug#end()

" Map normal mode for jj
inoremap jj <Esc>

" Exec commands at start
au StdinReadPre * let s:std_in=1
au VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
au VimEnter * NERDTreeToggle
au VimEnter * wincmd l

" Maps for switching panes
map <C-n> :NERDTreeToggle<CR>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" List symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>

" Enter for auto-complete
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
set nocompatible

if has('filetype')
  filetype indent plugin on
endif

if has('syntax')
  syntax on
endif

set wildmenu
set showcmd
set hlsearch
set ignorecase
set smartcase
set backspace=indent,eol,start
set autoindent
set nostartofline
set ruler
set laststatus=2
set confirm
set visualbell
set t_vb=

if has('mouse')
  set mouse=a
endif

set cmdheight=2
set notimeout ttimeout ttimeoutlen=200
set shiftwidth=4
set softtabstop=4
set expandtab
set noswapfile
set cindent
set nu
set softtabstop=2
set history=100

