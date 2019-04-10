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

function SetupCoc()
  call coc#util#install()
  execute '! npm install -g yarn rimraf copy-concurrently libcipm esparse normalize-package-data js-yaml mkdirp init-package-json http-signature lstat which cross-spawn libnpmpublish node-gyp dockerfile-language-server-nodejs typescript typescript-language-server yaml-language-server vscode-languageserver'
  execute '! pip install python-language-server'
  execute '! go get -u github.com/sourcegraph/go-langserver'
  execute '! go get -u github.com/awslabs/goformation'
  execute 'CocInstall coc-java'
  execute 'CocInstall coc-css coc-json coc-html'
  execute 'CocInstall coc-ultisnips coc-snippets'
  execute 'CocInstall coc-yaml'
  execute 'CocInstall coc-pyls'
  execute 'CocInstall coc-tsserver'
  execute 'CocInstall coc-tag'
endfunction

" START LSP-COMPLETION RELATED STUFF
Plug 'neoclide/coc.nvim', {'do': { -> SetupCoc()}}

" if hidden not set, TextEdit might fail.
set hidden

" Better display for messages
set cmdheight=2

" " Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" Use <C-l> to trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)
" Use <C-j> to select text for visual text of snippet.
vmap <C-j> <Plug>(coc-snippets-select)
" Use <C-j> to jump to forward placeholder, which is default
let g:coc_snippet_next = '<c-j>'
" Use <C-k> to jump to backward placeholder, which is default
let g:coc_snippet_prev = '<c-k>'

" STOP LSP-COMPLETION RELATED STUFF

Plug 'guns/xterm-color-table.vim'

Plug 'vim-scripts/L9'

Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

Plug 'rhysd/vim-clang-format'
if executable('clang-format-9')
  let g:clang_format#command = 'clang-format-9'
elseif executable('clang-format-8')
  let g:clang_format#command = 'clang-format-8'
endif

if has('nvim')
  Plug 'w0rp/ale'
  if executable('clang-tidy-9')
    let g:ale_cpp_clangtidy_executable = 'clang-tidy-9'
  elseif executable('clang-tidy-8')
    let g:ale_cpp_clangtidy_executable = 'clang-tidy-8'
  endif
  " only search for linters on startup
  let g:ale_cache_executable_check_failures = 1
  " disable fuchsia checker, annoying as hell
  let g:ale_cpp_clangtidy_checks = ["*", "-fuchsia*"]
  let g:airline#extensions#ale#enabled = 1
  " save some battery
  let g:ale_lint_delay = 1000
  " clang and g++ get includes wrong, so the linters are specified here
  let g:ale_linters_explicit = 1
  let g:ale_linters = {
        \   'cpp': ['clangtidy', 'cpplint', 'flawfinder'],
        \   'c': ['clangtidy', 'flawfinder'],
        \   'tex': ['chktex'],
        \   'python': ['flake8','pylint'],
        \}
  let g:ale_fixers = {
        \   'cpp': ['uncrustify'],
        \   'c': ['uncrustify'],
        \   'python': ['autopep8', 'yapf'],
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

Plug 'wincent/command-t', {
      \   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
      \ }

Plug 'godlygeek/tabular'
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
let g:Tex_ViewRule_pdf = 'evince 2>/dev/null'
if has("nvim")
  let g:vimtex_latexmk_progname = 'nvr'
endif

Plug 'peder2tm/sved'
function! SyncTexForward()
  call SVED_Sync()
endfunction
nmap <silent> <Leader>f :call SyncTexForward()<CR>


Plug 'avakhov/vim-yaml'

Plug 'elzr/vim-json'

Plug 'vim-scripts/Tabmerge'

Plug 'mkitt/tabline.vim'

Plug 'vim-scripts/indentpython.vim'

Plug 'vim-scripts/groovy.vim'
au BufNewFile,BufRead *.gradle setf groovy

Plug 'fatih/vim-go'
let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck']
let g:go_metalinter_autosave = 1
let g:go_version_warning = 0

Plug 'Shougo/vimproc.vim', {'do' : 'make'}
Plug 'idanarye/vim-vebugger'

" plantuml syntax highlighting and preview
Plug 'aklt/plantuml-syntax'

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
au BufRead * if search('\M-*- C++ -*-', 'n', 1) | setlocal filetype=cpp | endif

autocmd FileType cmake setlocal commentstring=#\ %s
autocmd FileType debsources setlocal commentstring=#\ %s
autocmd FileType java setlocal ts=4 sts=4 sw=4 expandtab autoindent
autocmd FileType python setlocal ts=4 sts=4 sw=4 tw=79 expandtab autoindent
autocmd FileType tex setlocal ts=4 sts=4 sw=4 spell spelllang=en
autocmd FileType c setlocal cindent expandtab
autocmd FileType c,cpp setlocal commentstring=//\ %s
autocmd FileType c,cpp,objc,ts,js,pb ClangFormatAutoEnable
autocmd FileType c,cpp,objc,ts,js,pb let g:clang_format#code_style = 'google'
autocmd FileType json setlocal ts=4 sts=4 sw=4

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

set exrc
set secure

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
