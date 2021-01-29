nnoremap <silent> <C-p> :Files<CR>

let g:fzf_buffers_jump = 1
let g:fzf_tags_command = 'ctags'

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }

