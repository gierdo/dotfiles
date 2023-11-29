function! SyncTexForward()
  call SVED_Sync()
endfunction
nmap <silent> <Leader>f :call SyncTexForward()<CR>
let g:tex_flavor = 'latex'
