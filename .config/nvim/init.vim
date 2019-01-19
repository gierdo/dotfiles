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

" START LSP-COMPLETION RELATED STUFF
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
let g:lsp_signs_enabled = 1         " enable signs
let g:lsp_diagnostics_echo_cursor = 1 " enable echo under cursor when in normal mode
map <leader>g :LspDefinition<CR>

" sudo apt-get install clang-tools-7
if executable('clangd-7')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd-7']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
elseif executable('clangd-6')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd-6']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
endif

" npm install -g dockerfile-language-server-nodejs
if executable('docker-langserver')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'docker-langserver',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'docker-langserver --stdio']},
        \ 'whitelist': ['dockerfile'],
        \ })
endif

" pip install python-language-server
if executable('pyls')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ 'workspace_config': {'pyls': {'plugins': {'pydocstyle': {'enabled': v:true}}}}
        \ })
endif

" npm install -g flow-language-server
if executable('flow-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'flow-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'flow-language-server --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), '.flowconfig'))},
        \ 'whitelist': ['javascript', 'javascript.jsx'],
        \ })
endif

" npm install -g typescript typescript-language-server
if executable('typescript-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
        \ 'whitelist': ['typescript'],
        \ })
endif

" go get -u github.com/sourcegraph/go-langserver
if executable('go-langserver')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'go-langserver',
        \ 'cmd': {server_info->['go-langserver', '-gocodecompletion']},
        \ 'whitelist': ['go'],
        \ })
endif

" STOP LSP-COMPLETION RELATED STUFF

if has('nvim')
  Plug 'roxma/nvim-yarp'
  Plug 'ncm2/ncm2', { 'do': ':UpdateRemotePlugins' }

  " NOTE: you need to install completion sources to get completions. Check
  " our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
  Plug 'ncm2/ncm2-vim-lsp'
  Plug 'ncm2/ncm2-bufword'
  Plug 'ncm2/ncm2-tmux'
  Plug 'ncm2/ncm2-path'
  Plug 'ncm2/ncm2-ultisnips'

  " enable ncm2 for all buffers
  autocmd BufEnter * call ncm2#enable_for_buffer()
  set completeopt=noinsert,menuone,noselect
  set shortmess+=c
endif

Plug 'ervandew/supertab'

Plug 'guns/xterm-color-table.vim'

Plug 'vim-scripts/L9'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
let g:UltiSnipsJumpForwardTrigger = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"
let g:UltiSnipsRemoveSelectModeMappings = 0

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

" The airline setup uses the powerline fonts, installed and configured as
" terminal font from this repo's submodule at ./powerline-fonts
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
let g:ctrlp_map = '<A-p>'

Plug 'godlygeek/tabular'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'Shougo/vimproc.vim'
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
map <silent> <C-n> :NERDTreeTabsToggle<CR>
let g:nerdtree_tabs_open_on_console_startup = 1


Plug 'vim-latex/vim-latex'
au BufEnter *.tex set autowrite
let g:Tex_FoldedSections=""
let g:Tex_FoldedEnvironments=""
let g:Tex_FoldedMisc=""
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats = 'pdf'
let g:Tex_CompileRule_pdf = 'pdflatex -synctex=1 -src-specials -interaction=nonstopmode $* && bibtex'
let g:Tex_GotoError = 0
let g:Tex_ViewRule_pdf = 'zathura 2>/dev/null'
function! SyncTexForward()
  let execstr = "silent !zathura --synctex-forward ".line(".").":".col(".").":%:p %:p:r.pdf &"
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

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    silent :e " this will reload the file without trickeries
              "(DOS line endings will be shown entirely )
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction
