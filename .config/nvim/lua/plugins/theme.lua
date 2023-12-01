local function configure_theme()
  vim.cmd [[
set background=dark
colorscheme solarized

autocmd VimEnter,ColorScheme * hi! ColorColumn cterm=bold ctermfg=255 ctermbg=0
autocmd VimEnter,ColorScheme * hi! link CocFloating CocHintFloat
autocmd VimEnter,ColorScheme * hi! CocMenuSel ctermbg=239 guibg=#13354A

" Force to use underline for spell check results
augroup SpellUnderline
  autocmd!
  autocmd ColorScheme *
    \ highlight SpellBad
    \   cterm=Underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  autocmd ColorScheme *
    \ highlight SpellCap
    \   cterm=Underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  autocmd ColorScheme *
    \ highlight SpellLocal
    \   cterm=Underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  autocmd ColorScheme *
    \ highlight SpellRare
    \   cterm=Underline
    \   ctermfg=NONE
    \   ctermbg=NONE
    \   term=Reverse
    \   gui=Undercurl
    \   guisp=Red
  augroup END

" Show trailing whitespace and spaces before a tab:
match ExtraWhitespace /\s\+$\| \+\ze\t/
autocmd VimEnter,ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen


let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
let g:indent_guides_exclude_filetypes = ['nerdtree', 'help']
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd ctermbg=23

]]
end


return {
  {
    'altercation/vim-colors-solarized',
    config = configure_theme,
    lazy = false,
    priority = 1000
  },
}
