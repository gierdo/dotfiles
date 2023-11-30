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

" Set Tab indentation rules
set ts=2 sts=2 sw=2 expandtab
map <leader>1 :set ts=1 sts=1 sw=1 expandtab <CR>
map <leader>2 :set ts=2 sts=2 sw=2 expandtab <CR>
map <leader>4 :set ts=4 sts=4 sw=4 expandtab <CR>
map <leader>8 :set ts=8 sts=8 sw=8 expandtab <CR>

" Us vertical splits for diffs per default
set diffopt+=vertical

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen
autocmd ColorScheme * highlight ColorColumn cterm=bold ctermfg=255 ctermbg=0
autocmd ColorScheme * hi CocMenuSel ctermbg=239 guibg=#13354A
