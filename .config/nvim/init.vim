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

if has('nvim')
  Plug 'sakhnik/nvim-gdb', { 'do': ':!./install.sh \| UpdateRemotePlugins' }
endif

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

Plug 'mileszs/ack.vim'
if executable('rg')
  let g:ackprg = 'rg --vimgrep --no-heading'
elseif executable('ag')
  let g:ackprg = 'ag --vimgrep --hidden'
endif
if !has('nvim')
  Plug 'tpope/vim-dispatch'
  let g:ack_use_dispatch = 1
endif
" Do not jump to the fist entry
cnoreabbrev Ack Ack!
cnoreabbrev ack Ack!

Plug 'wincent/command-t', {
      \   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
      \ }
nmap <silent> <C-p> :CommandT<CR>
let g:CommandTScanDotDirectories = 1
let g:CommandTAlwaysShowDotFiles = 0
let g:CommandTMaxFiles = 200000
let g:CommandTAcceptSelectionVSplitMap = "<C-v>"
let g:CommandTAcceptSelectionSplitMap = "<C-s>"

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

Plug 'vim-scripts/indentpython.vim'
Plug 'heavenshell/vim-pydocstring', { 'do': 'make clean && make install' }

Plug 'previm/previm'
if executable('chromium-browser')
  let g:previm_open_cmd = 'chromium-browser'
else
  let g:previm_open_cmd = 'firefox'
endif

Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Themes
Plug 'altercation/vim-colors-solarized'

" Put your non-Plug stuff after this line
call plug#end()

for vimrc in split(glob('~/.dotfiles/vimrc.d/*.vim'), "\n")
  exe 'source ' . vimrc
endfor
