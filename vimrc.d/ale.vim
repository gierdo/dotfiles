if has('nvim')
  " only search for linters on startup
  let g:ale_cache_executable_check_failures = 1
  " disable fuchsia checker, annoying as hell
  let g:ale_cpp_clangtidy_checks = ["*", "-fuchsia*", "-modernize-use-trailing-return-type"]
  let g:ale_c_clangtidy_checks = ["*", "-fuchsia*", "-modernize-use-trailing-return-type" ]
  let g:airline#extensions#ale#enabled = 1
  " save some battery
  let g:ale_lint_delay = 1000
  " clang and g++ get includes wrong, so the linters are specified here
  let g:ale_linters_explicit = 0
  let g:ale_linters = {
        \   'cpp': ['clangtidy', 'cppcheck', 'cpplint', 'flawfinder'],
        \   'c': ['clangtidy', 'cppcheck', 'flawfinder'],
        \   'tex': ['chktex'],
        \   'python': ['flake8','pylint'],
        \   'go': ['go build', 'gofmt', 'golint', 'go vet'],
        \   'java': [''],
        \}
  let g:ale_fix_on_save = 1
  let g:ale_fixers = {
        \   '*': ['remove_trailing_lines', 'trim_whitespace'],
        \   'cpp': ['clang-format', 'uncrustify', 'remove_trailing_lines', 'trim_whitespace'],
        \   'c': ['clang-format', 'uncrustify',  'remove_trailing_lines', 'trim_whitespace'],
        \   'python': ['autopep8', 'yapf', 'remove_trailing_lines', 'trim_whitespace'],
        \   'json': ['fixjson', 'jq', 'prettier', 'remove_trailing_lines', 'trim_whitespace'],
        \   'yaml': ['prettier', 'remove_trailing_lines', 'trim_whitespace'],
        \   'sh': ['shfmt', 'remove_trailing_lines', 'trim_whitespace'],
        \   'go': ['goimports', 'gofmt', 'remove_trailing_lines', 'trim_whitespace'],
        \   'rust': ['rustfmt', 'remove_trailing_lines', 'trim_whitespace'],
        \   'ruby': ['rubocop', 'remove_trailing_lines', 'trim_whitespace'],
        \}
  " If an uncrustify config is available in the home directory, use it
  let g:ale_c_uncrustify_options = '-c ~/.uncrustify.cfg'
  nmap <silent> <C-k> <Plug>(ale_previous_wrap)
  nmap <silent> <C-j> <Plug>(ale_next_wrap)
  command Nofix let g:ale_fix_on_save = 0
  command Yesfix let g:ale_fix_on_save = 1
endif
