
" fuzzy-find in current buffer
nnoremap <A-l> <cmd>Telescope current_buffer_fuzzy_find<cr>
" fuzzy-find in all files, slow and expensive
nnoremap <C-A-l> <cmd>Telescope grep_string search=''<cr>

" Find in all files
nnoremap <A-p> <cmd>Telescope live_grep<cr>
" Fuzzy-find paths
nnoremap <C-p> <cmd>Telescope find_files<cr>

nnoremap <C-A-b> <cmd>Telescope buffers<cr>
nnoremap <C-A-p> <cmd>Telescope tags<cr>
