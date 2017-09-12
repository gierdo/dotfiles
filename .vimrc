set wrap
set number
set cc=80
set encoding=utf-8
set mouse=a

set autoread

set clipboard=unnamedplus

nmap <F3> <C-]>
map <F4> :execute "vimgrep /" . expand("<cword>") . "/j **" <Bar> cw<CR>

colorscheme evening


autocmd FileType html setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType tex setlocal spell spelllang=en

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'

Plugin 'Valloric/YouCompleteMe'
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
:let g:ycm_collect_identifiers_from_tags_files=1

Plugin 'rdnetto/YCM-Generator'

Plugin 'tpope/vim-surround'
" Plugin 'flazz/vim-colorschemes'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline_theme='base16_ashes'
let g:airline_powerline_fonts = 1

Plugin 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'

Plugin 'scrooloose/nerdtree'
Bundle 'jistr/vim-nerdtree-tabs'
Plugin 'scrooloose/nerdcommenter'
nmap <silent> <leader>t :NERDTreeTabsToggle<CR>
" open nerdtree if no file was specified
autocmd StdinReadPre * let s:std_in=1
" toggle nerdtree with ctrl-n
map <C-n> :NERDTreeToggle<CR>
let g:nerdtree_tabs_open_on_console_startup = 1

Plugin 'kien/ctrlp.vim'

Plugin 'tpope/vim-commentary'

Plugin 'vim-latex/vim-latex'

au BufEnter *.tex set autowrite
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats = 'pdf'
let g:Tex_CompileRule_pdf = 'pdflatex -synctex=1 -src-specials -interaction=nonstopmode $*'
let g:Tex_GotoError = 0
"let g:Tex_ViewRule_pdf = 'evince'

let g:Tex_ViewRule_pdf = 'okular --unique 2>/dev/null'
function! SyncTexForward()
	     let execstr = "silent !okular --unique %:p:r.pdf\#src:".line(".")."%:p &"
	          exec execstr
	  endfunction
	  nmap <Leader>f :call SyncTexForward()<CR>

Plugin 'avakhov/vim-yaml'

Plugin 'godlygeek/tabular'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

	  
