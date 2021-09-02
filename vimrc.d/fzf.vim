" Search in files with strg + p
nnoremap <silent> <C-p> :Files<CR>
" Search in all text with alt + p
nnoremap <silent> <A-p> :Rg<CR>
" Search in tags with strg + alt + p
nnoremap <silent> <C-A-p> :Tags<CR>
" Search in open buffers with strg + l
nnoremap <silent> <C-l> :Lines<CR>

let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'ctags'

if has("nvim")
  au! TermOpen * tnoremap <buffer> <Esc> <c-\><c-n>
  au! FileType fzf tunmap <buffer> <Esc>
endif


" CTRL-A CTRL-Q to select all and build quickfix list

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_buffers_jump = 1

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
