" Set rules for specified filetypes
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
au BufNewFile,BufRead * if search('\M-*- C++ -*-', 'n', 1) | setlocal filetype=cpp | endif
au BufNewFile,BufRead *.gradle setf groovy
au BufNewFile,BufRead *.g set filetype=antlr3
au BufNewFile,BufRead *.g4 set filetype=antlr4

autocmd FileType java setlocal ts=4 sts=4 sw=4 expandtab autoindent
autocmd FileType python setlocal ts=4 sts=4 sw=4 tw=79 expandtab autoindent
autocmd FileType tex setlocal ts=4 sts=4 sw=4 spell spelllang=en,de_de
autocmd FileType md setlocal spell spelllang=en,de_de
autocmd FileType c setlocal cindent expandtab
autocmd FileType json setlocal ts=4 sts=4 sw=4
autocmd FileType json syntax match Comment +\/\/.\+$+
