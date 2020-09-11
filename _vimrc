set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

filetype off
set rtp+=~/.vim
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin('~/.vim/bundle')

Plugin 'VundleVim/Vundle.vim'
Plugin 'sickill/vim-monokai'
Plugin 'scrooloose/nerdtree'
Plugin 'shime/vim-livedown'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'aklt/plantuml-syntax'

call vundle#end()

filetype plugin indent on

colorscheme monokai

set gfn=D2Coding_ligature:h11:cHANGEUL:qDRAFT

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   General Setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Sets history line
set history=500

" Mapping <leader> => ,
let mapleader=","

" Show current position at bottom-right
set ruler

set lazyredraw

set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" Show line number
set number

" Set line number relative
set relativenumber

imap jj <ESC>

let g:plantuml_executable_script='java -jar D:\app\jars\plantuml.jar'


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   Search Setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Ignore case when searching
set ignorecase

" Be smart when searching
set smartcase

" Highlight search last result
set hlsearch

" Move cursor when searching
set incsearch


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   Color Setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Syntax Enable
syntax on

" Use color scheme 'seti'
"color seti



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   Indent Setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" tab == 4 space
set tabstop=4
set shiftwidth=4
set softtabstop=4

" Using tab like 4 space
set expandtab
set smarttab

" Auto Indent
set ai
" Smart Indent
set si


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   Key Mapping
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ,rc =>  Show edit tab .vimrc
nnoremap <leader>rc :rightbelow vnew $MYVIMRC<CR>

" ,src => Reload .vimrc
nnoremap <leader>src :source $MYVIMRC<CR>

" execute NERDTreeFind 
nnoremap <C-F> :NERDTreeFind<CR>
nnoremap <Leader>n :NERDTreeToggle<CR>

" ,q => Quit
map <leader>q <ESC><ESC>:q<CR>

" F2 => Save File
"imap <F2> <ESC><ESC>:w<CR>
map <F2> <ESC><ESC>:w<CR>

"복사 붙여넣기
map <F3> "+y
map <F4> "+gp
vmap <F3> "+y
vmap <F4> "+p
imap <F4> <ESC>"+pi

" jk => esc, Escape insert mode
inoremap jk <ESC>

nnoremap <leader>mm :LivedownToggle<CR>

" magic mode
nnoremap / /\v
vnoremap / /\v


nnoremap <F5> :w<CR> :silent make<CR>
inoremap <F5> <Esc>:w<CR>:silent make<CR>
vnoremap <F5> :<C-U>:w<CR>:silent make<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   Moving tab Setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

"H와 L을 라인 앞으로 뒤로
noremap H ^
noremap L $

set encoding=cp949
set fileencodings=utf-8,cp949
set langmenu=cp949
