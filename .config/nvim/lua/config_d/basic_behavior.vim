" Basic Behaviour
syntax on
set wrap
set number
set cc=80
set encoding=utf-8
set mouse=a
set noswapfile
set nobackup
set nowb
set wildmenu

" Searching
set ignorecase
set smartcase
" highlight search
set hls
" incremental search (while typing)
set is

set autoread
set exrc
set secure

" Reorder tabs on window resize
autocmd VimResized * wincmd =

" Copy-Paste from X-Buffer
set clipboard=unnamedplus

" Tag Navigation, relying on ctags
nmap <F3> g<C-]>

" Set default (dumb) Tab indentation rules
set ts=2 sts=2 sw=2 expandtab

" Us vertical splits for diffs per default
set diffopt+=vertical

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
