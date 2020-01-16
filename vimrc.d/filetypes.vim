" Set rules for specified filetypes
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
au BufRead * if search('\M-*- C++ -*-', 'n', 1) | setlocal filetype=cpp | endif
au BufNewFile,BufRead *.gradle setf groovy

autocmd FileType java setlocal ts=4 sts=4 sw=4 expandtab autoindent
autocmd FileType python setlocal ts=4 sts=4 sw=4 tw=79 expandtab autoindent
autocmd FileType tex setlocal ts=4 sts=4 sw=4 spell spelllang=en
autocmd FileType c setlocal cindent expandtab
autocmd FileType json setlocal ts=4 sts=4 sw=4
autocmd FileType json syntax match Comment +\/\/.\+$+
