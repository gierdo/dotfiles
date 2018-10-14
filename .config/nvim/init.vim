" Load vim-plug
if has('nvim')
  if empty(glob("~/.local/share/nvim/site/autoload/plug.vim"))
    execute '!curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim'
  endif
else
  if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim'
  endif
endif

" initialize plug
call plug#begin('~/.vim/plugged')

Plug 'guns/xterm-color-table.vim'

Plug 'vim-scripts/L9'

Plug 'Valloric/YouCompleteMe', {'do': './install.py --clang-completer --go-completer --rust-completer --java-completer'}
" let g:ycm_autoclose_preview_window_after_completion = 1
" let g:ycm_autoclose_preview_window_after_insertion = 1
" let g:ycm_auto_trigger = 1
let g:ycm_semantic_triggers = { 'c': [ 're!\w{2}' ] }
let g:ycm_global_ycm_extra_conf = '~/.dotfiles/.ycm_extra_conf.py'
let g:ycm_collect_identifiers_from_tags_files=1
let g:ycm_extra_conf_globlist = ['./*','~/.dotfiles/*','!~/*']
let g:ycm_filetype_whitelist = {
      \'c': 1,
      \'cpp': 1,
      \'python': 1,
      \'objc': 1,
      \'ts': 1,
      \'js': 1,
      \'go': 1,
      \'rust': 1,
      \'java': 1
      \}
let g:ycm_confirm_extra_conf = 1
let g:ycm_min_num_identifier_candidate_chars = 0
let g:ycm_max_num_candidates = 60
let g:ycm_max_num_identifier_candidates = 20
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_min_num_of_chars_for_completion = 1
let g:ycm_error_symbol = '>>'
let g:ycm_warning_symbol = '>>'
let g:ycm_complete_in_comments = 1
let g:ycm_complete_in_strings = 1
let g:ycm_seed_identifiers_with_syntax = 1
let g:ycm_key_list_select_completion = ['<C-j>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>']
map <leader>g :YcmCompleter GoTo<CR>

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsExpandTrigger = "<C-l>"
let g:UltiSnipsJumpForwardTrigger = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"

Plug 'rhysd/vim-clang-format'
if executable('clang-format-7')
  let g:clang_format#command = 'clang-format-7'
elseif executable('clang-format-6.0')
  let g:clang_format#command = 'clang-format-6.0'
endif

if has('nvim')
  Plug 'w0rp/ale'
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
        \   'cpp': ['clangtidy', 'cpplint', 'flawfinder'],
        \   'c': ['clangtidy', 'flawfinder'],
        \}
  nmap <silent> <C-k> <Plug>(ale_previous_wrap)
  nmap <silent> <C-j> <Plug>(ale_next_wrap)
endif

Plug 'tpope/vim-surround'

Plug 'vim-scripts/DoxygenToolkit.vim'

" The airline setup uses the powerline fonts, installed from here:
" https://github.com/powerline/fonts
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='atomic'
let g:airline_powerline_fonts = 1

Plug 'nathanaelkane/vim-indent-guides'
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 0
let g:indent_guides_exclude_filetypes = ['nerdtree']
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=237
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermbg=235

Plug 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

Plug 'mileszs/ack.vim'
Plug 'kien/ctrlp.vim'
Plug 'godlygeek/tabular'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'Shougo/vimproc.vim'
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
map <silent> <C-n> :NERDTreeTabsToggle<CR>
" let g:nerdtree_tabs_open_on_console_startup = 1


Plug 'vim-latex/vim-latex'
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

Plug 'avakhov/vim-yaml'

Plug 'elzr/vim-json'

Plug 'vim-scripts/indentpython.vim'

Plug 'ekalinin/Dockerfile.vim'

Plug 'fatih/vim-go'
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave = 1
let g:go_version_warning = 0

" Put your non-Plug stuff after this line
call plug#end()
" Brief help
" :PlugInstall [name ...] [#threads]	Install plugins
" :PlugUpdate [name ...] [#threads]	Install or update plugins
" :PlugClean[!]	Remove unused directories (bang version will clean without prompt)
" :PlugUpgrade	Upgrade vim-plug itself
" :PlugStatus	Check the status of plugins
" :PlugDiff	Examine changes from the previous update and the pending changes
" :PlugSnapshot[!] [output path]	Generate script for restoring the current snapshot of the plugins
"

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

" Auto Update files
set autoread

" Color scheme settings, including color of extra whitespaces

autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen
autocmd ColorScheme * highlight DiffAdd     cterm=bold ctermfg=2 ctermbg=27
autocmd ColorScheme * highlight DiffDelete  cterm=bold ctermfg=2 ctermbg=27
autocmd ColorScheme * highlight DiffChange  cterm=bold ctermfg=2 ctermbg=27
autocmd ColorScheme * highlight DiffText    cterm=bold ctermfg=2 ctermbg=88
autocmd ColorScheme * highlight ColorColumn cterm=bold ctermfg=255 ctermbg=240
colorscheme industry

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


" Set Tab indentation rules
set ts=2 sts=2 sw=2 expandtab
map <leader>1 :set ts=1 sts=1 sw=1 expandtab <CR>
map <leader>2 :set ts=2 sts=2 sw=2 expandtab <CR>
map <leader>4 :set ts=4 sts=4 sw=4 expandtab <CR>
map <leader>8 :set ts=8 sts=8 sw=8 expandtab <CR>

" Set rules for specified filetypes
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
autocmd FileType cmake setlocal commentstring=#\ %s
autocmd FileType debsources setlocal commentstring=#\ %s
autocmd FileType python setlocal ts=4 sts=4 sw=4 tw=79 expandtab autoindent
autocmd FileType tex setlocal ts=4 sts=4 sw=4 spell spelllang=en
autocmd FileType c setlocal cindent expandtab
autocmd FileType c,cpp,objc,ts,js,pb ClangFormatAutoEnable
autocmd FileType c,cpp,objc,ts,js,pb let g:clang_format#code_style = 'google'
autocmd FileType json setlocal ts=4 sts=4 sw=4
