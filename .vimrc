" This vim setup uses vundle for vim plugin management.
" Vundle installation:
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'guns/xterm-color-table.vim'

" plugin from http://vim-scripts.org/vim/scripts.html
Plugin 'L9'

" YouCompleteMe has to be installed after the first run of PluginInstall:
" ~/.vim/bundle/YouCompleteMe/install.sh --clang-completer
Plugin 'Valloric/YouCompleteMe'
let g:ycm_global_ycm_extra_conf = '~/.dotfiles/.ycm_extra_conf.py'
let g:ycm_collect_identifiers_from_tags_files=1
let g:ycm_extra_conf_globlist = ['./*','~/.dotfiles/*','!~/*']
let g:ycm_auto_trigger = 1
let g:ycm_filetype_whitelist = { '*': 1 }
let g:ycm_confirm_extra_conf = 1
let g:ycm_min_num_identifier_candidate_chars = 0
let g:ycm_max_num_candidates = 60
let g:ycm_max_num_identifier_candidates = 20
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_error_symbol = '>>'
let g:ycm_warning_symbol = '>>'
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_seed_identifiers_with_syntax = 1
map <leader>g :YcmCompleter GoTo<CR>

Plugin 'rhysd/vim-clang-format'
if executable('clang-format-7')
  let g:clang_format#command = 'clang-format-7'
elseif executable('clang-format-6.0')
  let g:clang_format#command = 'clang-format-6.0'
endif

Plugin 'w0rp/ale'
if executable('clang-tidy-7')
  let g:ale_cpp_clangtidy_executable = 'clang-tidy-7'
elseif executable('clang-tidy-6.0')
  let g:ale_cpp_clangtidy_executable = 'clang-tidy-6.0'
endif
" only search for linters on startup
let g:ale_cache_executable_check_failures = 1
" disable fuchsia checker, annoying as hell
let g:ale_cpp_clangtidy_checks = ["*", "-fuchsia*"]
let g:airline#extensions#ale#enabled = 1
" save some battery
let g:ale_lint_delay = 1000
" clang and g++ get includes wrong, so the linters are specified here
let g:ale_linters = {
      \   'cpp': ['clangcheck', 'clangtidy', 'cppcheck', 'cpplint', 'flawfinder'],
      \   'c': ['clangcheck', 'clangtidy', 'flawfinder'],
      \}
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

Plugin 'tpope/vim-surround'

Plugin 'vim-scripts/DoxygenToolkit.vim'

" The airline setup uses the powerline fonts, installed from here:
" https://github.com/powerline/fonts
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
let g:airline_theme='atomic'
let g:airline_powerline_fonts = 1

Plugin 'nathanaelkane/vim-indent-guides'
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_exclude_filetypes = ['nerdtree']
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=237
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermbg=235


Plugin 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

Plugin 'mileszs/ack.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'godlygeek/tabular'
Plugin 'jeetsukumaran/vim-buffergator'
Plugin 'Shougo/vimproc.vim'
Plugin 'tpope/vim-commentary'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-fugitive'

Plugin 'scrooloose/nerdtree'
Bundle 'jistr/vim-nerdtree-tabs'
" toggle nerdtree with ctrl-n
map <silent> <C-n> :NERDTreeTabsToggle<CR>
let g:nerdtree_tabs_open_on_console_startup = 1

" Language or filetype specific plugins:

Plugin 'vim-latex/vim-latex'

au BufEnter *.tex set autowrite
let g:Tex_FoldedSections=""
let g:Tex_FoldedEnvironments=""
let g:Tex_FoldedMisc=""
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats = 'pdf'
let g:Tex_CompileRule_pdf = 'pdflatex -synctex=1 -src-specials -interaction=nonstopmode $* && bibtex'
let g:Tex_GotoError = 0
let g:Tex_ViewRule_pdf = 'okular --unique 2>/dev/null'
function! SyncTexForward()
  let execstr = "silent !okular --unique %:p:r.pdf\\#src:".line(".")."%:p 2>/dev/null &"
  exec execstr
  redraw!
endfunction
nmap <Leader>f :call SyncTexForward()<CR>

if has("nvim")
  let g:vimtex_latexmk_progname = 'nvr'
endif

Plugin 'avakhov/vim-yaml'

Plugin 'rust-lang/rust.vim'

Plugin 'pangloss/vim-javascript.git'
Plugin 'elzr/vim-json'
Plugin 'leafgarland/typescript-vim.git'
autocmd BufNewFile,BufFilePre,BufRead *.tsx set filetype=typescript

Plugin 'idanarye/vim-vebugger'

Plugin 'vim-scripts/indentpython.vim'

Plugin 'ekalinin/Dockerfile.vim'

Plugin 'fatih/vim-go'
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave = 1

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

" Basic Behaviour
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

" Auto Update files
set autoread

" Color scheme settings, including color of extra whitespaces

autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen
autocmd ColorScheme * highlight DiffAdd     cterm=bold ctermfg=2 ctermbg=27
autocmd ColorScheme * highlight DiffDelete  cterm=bold ctermfg=2 ctermbg=27
autocmd ColorScheme * highlight DiffChange  cterm=bold ctermfg=2 ctermbg=27
autocmd ColorScheme * highlight DiffText    cterm=bold ctermfg=2 ctermbg=88
autocmd ColorScheme * highlight ColorColumn cterm=bold ctermfg=255 ctermbg=240
colorscheme default

" Remove trailing whitespace for all but specified filetypes
fun! RemoveTrailingWhitespace()
  " Don't strip on these filetypes
  if &ft =~ 'ruby\|perl'
    return
  endif
  %s/\s\+$//e
endfun

autocmd BufWritePre * call RemoveTrailingWhitespace()

" Show trailing whitespace and spaces before a tab:
match ExtraWhitespace /\s\+$\| \+\ze\t/

" Reorder tabs on window resize
autocmd VimResized * wincmd =

" Copy-Paste from X-Buffer
set clipboard=unnamedplus

" Tag Navigation, relying on ctags
nmap <F3> g<C-]>

" Nerdtree magic
autocmd FileType nerdtree let t:nerdtree_winnr = bufwinnr('%')
autocmd BufWinEnter * call PreventBuffersInNERDTree()

function! PreventBuffersInNERDTree()
  if bufname('#') =~ 'NERD_tree' && bufname('%') !~ 'NERD_tree'
        \ && exists('t:nerdtree_winnr') && bufwinnr('%') == t:nerdtree_winnr
        \ && &buftype == ''
    let bufnum = bufnr('%')
    close
    exe 'b ' . bufnum
    exe 'NERDTreeTabsOpen'
    exe 'NERDTreeFocusToggle'
  endif
endfunction

" Open Quickfix window at the bottom
:autocmd FileType qf wincmd J

" Auto filetype settings
filetype plugin indent on
syntax on

" Set Tab indentation rules
set ts=2 sts=2 sw=2 expandtab
map <leader>1 :set ts=1 sts=1 sw=1 expandtab <CR>
map <leader>2 :set ts=2 sts=2 sw=2 expandtab <CR>
map <leader>4 :set ts=4 sts=4 sw=4 expandtab <CR>
map <leader>8 :set ts=8 sts=8 sw=8 expandtab <CR>

" Set rules for specified filetypes
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
autocmd FileType cmake setlocal commentstring=#\ %s
autocmd FileType python setlocal ts=4 sts=4 sw=4 tw=79 expandtab autoindent
autocmd FileType tex setlocal ts=4 sts=4 sw=4 spell spelllang=en
autocmd FileType c setlocal cindent expandtab
autocmd FileType c,cpp,objc,ts,js,pb ClangFormatAutoEnable
autocmd FileType c,cpp,objc,ts,js,pb let g:clang_format#code_style = 'google'
autocmd FileType json setlocal ts=4 sts=4 sw=4
