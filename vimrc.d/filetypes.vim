" Set rules for specified filetypes
au BufNewFile,BufRead CMakeLists.txt set filetype=cmake
au BufNewFile,BufRead * if search('\M-*- C++ -*-', 'n', 1) | setlocal filetype=cpp | endif
au BufNewFile,BufRead *.gradle set filetype=groovy
au BufNewFile,BufRead *.g set filetype=antlr3
au BufNewFile,BufRead *.g4 set filetype=antlr4
au BufNewFile,BufRead *.template.y*ml set filetype=cloudformation.yaml
au BufNewFile,BufRead *.template.json set filetype=cloudformation.json

autocmd FileType java setlocal ts=4 sts=4 sw=4 expandtab autoindent
autocmd FileType python setlocal ts=4 sts=4 sw=4 expandtab autoindent cc=120
autocmd FileType tex setlocal ts=4 sts=4 sw=4 spell spelllang=en_gb,de_de
autocmd FileType markdown setlocal spell spelllang=en_gb,de_de
autocmd FileType c setlocal cindent expandtab

autocmd FileType json setlocal ts=4 sts=4 sw=4
autocmd FileType json syntax match Comment +\/\/.\+$+
com! FormatJSON %!python -m json.tool

set wildignore+=*.o,*.obj,**/.git/*,**/.svn/*,**/node_modules/**,node_modules/**,.git/*,svn/*,.ctags
