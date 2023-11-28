" Vim and vundle require a posix compliant shell
set shell=sh

if empty(glob("~/.local/share/nvim/site/autoload/plug.vim"))
  execute '!curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.github.com/junegunn/vim-plug/master/plug.vim'
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
" Shared library for lua plugins
Plug 'nvim-lua/plenary.nvim'

" shared UI library
Plug 'MunifTanjim/nui.nvim'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': { -> SetupCoc()}}

Plug 'neoclide/coc-css', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-html', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-java', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-lists', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-prettier', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-tsserver', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-snippets', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-vimtex', {'do': 'yarn install --frozen-lockfile'}
Plug 'neoclide/coc-yaml', {'do': 'yarn install --frozen-lockfile'}
Plug 'pappasam/coc-jedi', {'do': 'yarn install --frozen-lockfile'}
Plug 'josa42/coc-docker', {'do': 'yarn install --frozen-lockfile'}
Plug 'iamcco/coc-diagnostic', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-xml', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-markdownlint', {'do': 'yarn install --frozen-lockfile'}
Plug 'fannheyward/coc-pyright', {'do': 'yarn install --frozen-lockfile'}
Plug 'joenye/coc-cfn-lint', {'do': 'yarn install --pure-lockfile'}
Plug 'weirongxu/coc-kotlin', {'do': 'yarn install --pure-lockfile'}
Plug 'xiyaowong/coc-sumneko-lua', {'do': 'yarn install --pure-lockfile'}

Plug 'w0rp/ale'

Plug 'gierdo/neoai.nvim', { 'branch': 'local-llama' }

if v:lua.vim.version().major == 0 && v:lua.vim.version().minor < 8
  Plug 'folke/todo-comments.nvim', { 'branch': 'neovim-pre-0.8.0' }
else
  Plug 'folke/todo-comments.nvim'
endif

Plug 'guns/xterm-color-table.vim'
Plug 'vim-scripts/L9'

" Work with parentheses
Plug 'tpope/vim-surround'

" Autoclose parentheses etc.
Plug 'vim-scripts/delimitMate.vim'
Plug 'scrooloose/nerdcommenter'
let g:NERDCustomDelimiters = {
      \ 'c': { 'left': '/*','right': '*/' },
      \ 'debsources': { 'left': '#'},
      \ 'cmake': { 'left': '#'}
      \}
let g:NERDDefaultAlign = 'left'
let g:NERDCompactSexyComs = 0
let g:NERDSpaceDelims = 1

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'justinmk/vim-gtfo'

let g:NERDTreeMapOpenInTab = "<C-t>"
let g:NERDTreeMapOpenVSplit = "<C-v>"
let g:NERDTreeMapOpenSplit = "<C-s>"

Plug 'luochen1990/rainbow'

Plug 'powerman/vim-plugin-AnsiEsc'

Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'nvim-tree/nvim-web-devicons'
Plug 'ryanoasis/vim-devicons'

Plug 'preservim/vim-indent-guides'

Plug 'soramugi/auto-ctags.vim'
Plug 'liuchengxu/vista.vim'
nmap <silent> <F8> :Vista!!<CR>

" Auto indentation
Plug 'vim-scripts/yaifa.vim'
let yaifa_max_lines = 4096

Plug 'junegunn/fzf', { 'do': './install --all' }

Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }

Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'fannheyward/telescope-coc.nvim'
Plug 'nvim-telescope/telescope-github.nvim'

Plug 'godlygeek/tabular'
Plug 'dhruvasagar/vim-table-mode'

Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'lervag/vimtex'
Plug 'peder2tm/sved'
function! SyncTexForward()
  call SVED_Sync()
endfunction
nmap <silent> <Leader>f :call SyncTexForward()<CR>
let g:tex_flavor = 'latex'

Plug 'udalov/kotlin-vim'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

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

Plug 'heavenshell/vim-pydocstring', { 'do': 'make clean && make install' }
Plug 'goerz/jupytext.vim', { 'do': 'pip install --upgrade jupytext' }

Plug 'jxnblk/vim-mdx-js'

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

" This is overriden if put in the coc config
hi link CocFloating ALEErrorSign
