" only search for linters on startup
let g:ale_cache_executable_check_failures = 1
let g:airline#extensions#ale#enabled = 1
" save some battery
let g:ale_lint_delay = 1000
" clang and g++ get includes wrong, so the linters are specified here
let g:ale_linters_explicit = 0
let g:ale_linters = {
      \   'cpp': ['clangtidy', 'cppcheck', 'cpplint', 'flawfinder'],
      \   'python': ['mypy', 'pylint', 'flake8'],
      \   'c': ['clangtidy', 'cppcheck', 'flawfinder'],
      \   'yaml': ['yamllint'],
      \   'cloudformation.yaml': ['cloudformation', 'yamllint'],
      \   'java': [''],
      \}

let g:ale_fix_on_save = 1
let g:ale_fixers = {
      \   '*': ['trim_whitespace'],
      \   'cpp': ['trim_whitespace'],
      \   'c': ['trim_whitespace'],
      \   'python': ['trim_whitespace'],
      \   'json': ['fixjson', 'jq', 'trim_whitespace'],
      \   'yaml': ['trim_whitespace'],
      \   'sh': ['shfmt', 'trim_whitespace'],
      \   'go': ['goimports', 'gofmt', 'trim_whitespace'],
      \   'rust': ['rustfmt', 'trim_whitespace'],
      \   'ruby': ['rubocop', 'trim_whitespace'],
      \   'typescript': ['tslint', 'trim_whitespace'],
      \}

" disable fuchsia checker, annoying as hell
let g:ale_cpp_clangtidy_checks = ["*", "-fuchsia*", "-modernize-use-trailing-return-type", "-llvmlibc-*"]
let g:ale_c_clangtidy_checks = ["*", "-fuchsia*", "-modernize-use-trailing-return-type" , "-llvmlibc-*"]
let g:ale_python_pylint_options = "--rcfile ~/.dotfiles/google-styleguide/python/pylintrc --indent-string='    ' --max-line-length=120 --disable=C0114 --disable=C0115 --disable=W1203"
let g:ale_python_flake8_options = '--max-line-length=120'
" If an uncrustify config is available in the home directory, use it
let g:ale_c_uncrustify_options = '-c ~/.uncrustify.cfg'
" Indent with 2 spaces
let g:ale_sh_shfmt_options = '-i 2'
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)
command Nofix let g:ale_fix_on_save = 0
command Yesfix let g:ale_fix_on_save = 1
