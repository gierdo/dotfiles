" only search for linters on startup
let g:ale_cache_executable_check_failures = 1
let g:airline#extensions#ale#enabled = 1
" save some battery
let g:ale_lint_delay = 1000
" clang and g++ get includes wrong, so the linters are specified here
let g:ale_linters_explicit = 0
let g:ale_linters = {
      \   'cpp': ['clangtidy', 'cppcheck', 'cpplint', 'flawfinder'],
      \   'c': ['clangtidy', 'cppcheck', 'flawfinder'],
      \   'java': [''],
      \}
let g:ale_fix_on_save = 1
let g:ale_fixers = {
      \   '*': ['trim_whitespace'],
      \   'cpp': ['clang-format', 'uncrustify', 'trim_whitespace'],
      \   'c': ['clang-format', 'uncrustify',  'trim_whitespace'],
      \   'python': ['trim_whitespace'],
      \   'json': ['fixjson', 'jq', 'prettier', 'trim_whitespace'],
      \   'yaml': ['prettier', 'trim_whitespace'],
      \   'sh': ['shfmt', 'trim_whitespace'],
      \   'go': ['goimports', 'gofmt', 'trim_whitespace'],
      \   'rust': ['rustfmt', 'trim_whitespace'],
      \   'ruby': ['rubocop', 'trim_whitespace'],
      \   'typescript': ['prettier', 'tslint', 'trim_whitespace'],
      \}

" disable fuchsia checker, annoying as hell
let g:ale_cpp_clangtidy_checks = ["*", "-fuchsia*", "-modernize-use-trailing-return-type", "-llvmlibc-*"]
let g:ale_c_clangtidy_checks = ["*", "-fuchsia*", "-modernize-use-trailing-return-type" , "-llvmlibc-*"]
let g:ale_python_pylint_options = "--rcfile ~/.dotfiles/google-styleguide/python/pylintrc --indent-string='    '"
" If an uncrustify config is available in the home directory, use it
let g:ale_c_uncrustify_options = '-c ~/.uncrustify.cfg'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
command Nofix let g:ale_fix_on_save = 0
command Yesfix let g:ale_fix_on_save = 1
