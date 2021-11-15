" Vim and vundle require a posix compliant shell
set shell=sh

if has('nvim')
  if empty(glob("~/.local/share/nvim/site/autoload/plug.vim"))
    execute '!curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim'
  endif
else
  if empty(glob("~/.vim/autoload/plug.vim"))
    execute '!curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim'
  endif
endif

" Brief help
" :PlugInstall [name ...] [#threads]	Install plugins
" :PlugUpdate [name ...] [#threads]	Install or update plugins
" :PlugClean[!]	Remove unused directories (bang version will clean without prompt)
" :PlugUpgrade	Upgrade vim-plug itself
" :PlugStatus	Check the status of plugins
" :PlugDiff	Examine changes from the previous update and the pending changes
" :PlugSnapshot[!] [output path]	Generate script for restoring the current snapshot of the plugins
"
call plug#begin('~/.vim/plugged')

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'neoclide/coc.nvim', {'do': { -> SetupCoc()}}
Plug 'w0rp/ale'

" Debugger
Plug 'puremourning/vimspector'
let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
let g:vimspector_install_gadgets = [ 'debugpy', 'vscode-cpptools' ]

Plug 'guns/xterm-color-table.vim'
Plug 'vim-scripts/L9'
Plug 'tpope/vim-surround'
Plug 'scrooloose/nerdcommenter'
let g:NERDCustomDelimiters = {
      \ 'c': { 'left': '/*','right': '*/' },
      \ 'debsources': { 'left': '#'},
      \ 'cmake': { 'left': '#'}
      \}
let g:NERDDefaultAlign = 'left'
let g:NERDCompactSexyComs = 0
let g:NERDSpaceDelims = 1
let g:NERDTreeMapOpenVSplit = "<C-v>"
let g:NERDTreeMapOpenSplit = "<C-s>"

Plug 'luochen1990/rainbow'

Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'jsfaint/gen_tags.vim'
Plug 'majutsushi/tagbar'
nmap <F8> :TagbarToggle<CR>

" Auto indentation
Plug 'vim-scripts/yaifa.vim'
let yaifa_max_lines = 4096

Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'godlygeek/tabular'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'justinmk/vim-gtfo'

Plug 'lervag/vimtex'
Plug 'peder2tm/sved'
function! SyncTexForward()
  call SVED_Sync()
endfunction
nmap <silent> <Leader>f :call SyncTexForward()<CR>
let g:tex_flavor = 'latex'

Plug 'dylon/vim-antlr'
Plug 'jamessan/vim-gnupg'
Plug 'elzr/vim-json'
Plug 'vim-scripts/Tabmerge'
Plug 'mkitt/tabline.vim'
Plug 'jeetsukumaran/vim-buffergator'
Plug 'vim-scripts/groovy.vim'
Plug 'leafgarland/typescript-vim'
Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'aklt/plantuml-syntax'
Plug 'HiPhish/guile.vim'
Plug 'kovisoft/slimv', {'rtp': 'vim/'}
let g:slimv_swank_cmd = '! tmux new-window -d -n REPL-SBCL "sbcl --load ~/.vim/bundle/slimv/slime/start-swank.lisp"'

Plug 'vim-scripts/indentpython.vim'
Plug 'heavenshell/vim-pydocstring', { 'do': 'make clean && make install' }
Plug 'goerz/jupytext.vim', { 'do': 'pip install --upgrade jupytext' }

Plug 'previm/previm'
if executable('x-www-browser')
  let g:previm_open_cmd = 'x-www-browser'
else
  let g:previm_open_cmd = 'firefox'
endif

Plug 'hashivim/vim-terraform'

Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Themes
Plug 'altercation/vim-colors-solarized'

" Put your non-Plug stuff after this line
call plug#end()

for vimrc in split(glob('~/.dotfiles/vimrc.d/*.vim'), "\n")
  exe 'source ' . vimrc
endfor
