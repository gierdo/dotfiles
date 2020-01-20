" The airline setup uses the powerline fonts, installed and configured as
" terminal font. Vim-devicons requires nerd-fonts, which also contain the
" powerline symbols.
" Some fonts are available from the fonts directory for installation.


autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen
autocmd ColorScheme * highlight ColorColumn cterm=bold ctermfg=255 ctermbg=240

colorscheme solarized
set background=dark

" Show trailing whitespace and spaces before a tab:
match ExtraWhitespace /\s\+$\| \+\ze\t/

let g:airline_theme='atomic'
let g:airline_powerline_fonts = 1

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_auto_colors = 1
let g:indent_guides_exclude_filetypes = ['nerdtree']
