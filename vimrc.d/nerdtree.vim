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

map <silent> <C-n> :NERDTreeTabsToggle<CR>
let g:nerdtree_tabs_open_on_console_startup = 1
