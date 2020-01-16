if has('nvim')

  " if hidden not set, TextEdit might fail.
  set hidden
  "
  " Better display for messages
  set cmdheight=2

  " " Smaller updatetime for CursorHold & CursorHoldI
  set updatetime=300

  " don't give |ins-completion-menu| messages.
  set shortmess+=c

  " Use tab for trigger completion with characters ahead and navigate.
  " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  " Use <c-space> for trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()

  " Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
  " Coc only does snippet and additional edit on confirm.
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

  " Use `[g` and `]g` for navigate diagnostics
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " Remap keys for gotos
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  " Use readable colors for floating overlay messages
  hi link CocFloating ALEErrorSign

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Highlight symbol under cursor on CursorHold
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Remap for rename current word
  nmap <leader>rn <Plug>(coc-rename)

  " Remap for format selected region
  xmap <leader>f  <Plug>(coc-format-selected)
  nmap <leader>f  <Plug>(coc-format-selected)

  " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
  xmap <leader>a  <Plug>(coc-codeaction-selected)
  nmap <leader>a  <Plug>(coc-codeaction-selected)

  " Remap for do codeAction of current line
  nmap <leader>ac  <Plug>(coc-codeaction)
  " Fix autofix problem of current line
  nmap <leader>qf  <Plug>(coc-fix-current)

  " Create mappings for function text object, requires document symbols feature of languageserver.
  xmap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap if <Plug>(coc-funcobj-i)
  omap af <Plug>(coc-funcobj-a)

  " Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
  nmap <silent> <TAB> <Plug>(coc-range-select)
  xmap <silent> <TAB> <Plug>(coc-range-select)

  " Use `:Format` to format current buffer
  command! -nargs=0 Format :call CocAction('format')

  " Use `:Fold` to fold current buffer
  command! -nargs=? Fold :call     CocAction('fold', <f-args>)

  " use `:OR` for organize import of current buffer
  command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

  " Add status line support, for integration with other plugin, checkout `:h coc-status`
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " Using CocList
  " Show all diagnostics
  nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
  " Manage extensions
  nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
  " Show commands
  nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
  " Find symbol of current document
  nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
  " Search workspace symbols
  nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
  " Do default action for next item.
  nnoremap <silent> <space>j  :<C-u>CocNext<CR>
  " Do default action for previous item.
  nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
  " Resume latest coc list
  nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
  " Use <C-l> to trigger snippet expand.
  imap <C-l> <Plug>(coc-snippets-expand)
  " Use <C-j> to select text for visual text of snippet.
  vmap <C-j> <Plug>(coc-snippets-select)
  " Use <C-j> to jump to forward placeholder, which is default
  let g:coc_snippet_next = '<c-j>'
  " Use <C-k> to jump to backward placeholder, which is default
  let g:coc_snippet_prev = '<c-k>'


  function SetupCoc()
    call coc#util#install()
    execute '! npm install -g --update yarn'
    execute '! yarn install --frozen-lockfile'
    execute '! npm install -g --update rimraf copy-concurrently libcipm esparse normalize-package-data js-yaml mkdirp init-package-json http-signature lstat which cross-spawn libnpmpublish node-gyp dockerfile-language-server-nodejs typescript typescript-language-server yaml-language-server vscode-languageserver bash-language-server'
    execute '! pip install --user --upgrade python-language-server pylint'
    execute '! go get -u github.com/sourcegraph/go-langserver'
    execute '! go get -u github.com/awslabs/goformation'
    execute '! go get -u golang.org/x/lint/golint'
    execute '! go get -u golang.org/x/tools/cmd/goimports'
    execute 'CocInstall coc-java'
    execute 'CocInstall coc-css'
    execute 'CocInstall coc-json'
    execute 'CocInstall coc-html'
    execute 'CocInstall coc-ultisnips'
    execute 'CocInstall coc-snippets'
    execute 'CocInstall coc-yaml'
    execute 'CocInstall coc-python'
    execute 'CocInstall coc-tsserver'
    execute 'CocInstall coc-tslint-plugin'
    execute 'CocInstall coc-tag'
    execute 'CocInstall coc-vimtex'
    execute 'CocInstall coc-rls'
    execute 'CocInstall coc-solargraph'
  endfunction

endif
