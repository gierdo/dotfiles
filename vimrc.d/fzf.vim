" Search in files with strg + p
nnoremap <silent> <C-p> :Files<CR>
" Search in all text with alt + p
nnoremap <silent> <A-p> :Rg<CR>
" Search in tags with strg + alt + p
nnoremap <silent> <C-A-p> :Tags<CR>

let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'ctags'

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }
