local function configure_ale()
      -- only search for linters on startup
      vim.g.ale_cache_executable_check_failures = 1
      vim.cmd("let g:airline#extensions#ale#enabled = 1")
      vim.g.ale_lint_delay = 1000
      vim.g.ale_linters_explicit = 0
      vim.g.ale_fix_on_save = 1
      vim.g.ale_kotlin_ktlint_options = "--log-level=error --disabled_rules=trailing-comma-on-declaration-site"
      --
      -- disable fuchsia checker, annoying as hell
      vim.g.ale_cpp_clangtidy_checks = { "*", "-fuchsia*", "-modernize-use-trailing-return-type", "-llvmlibc-*" }
      vim.g.ale_c_clangtidy_checks = { "*", "-fuchsia*", "-modernize-use-trailing-return-type", "-llvmlibc-*" }
      vim.g.ale_python_flake8_options = '--max-line-length=120'
      vim.g.ale_c_uncrustify_options = '-c ~/.uncrustify.cfg'
      vim.g.ale_sh_shfmt_options = '-i 2'

      vim.keymap.set("n", "<C-k>", "<Plug>(ale_previous_wrap)", { silent = true })
      vim.keymap.set("n", "<C-j>", "<Plug>(ale_next_wrap)", { silent = true })
      vim.cmd("command Nofix let g:ale_fix_on_save = 0")
      vim.cmd("command Yesfix let g:ale_fix_on_save = 1")
      vim.cmd [[
let g:ale_linters = {
      \   'cpp': ['clangtidy', 'cppcheck', 'cpplint', 'flawfinder'],
      \   'python': ['mypy', 'pylint', 'flake8', 'bandit'],
      \   'c': ['clangtidy', 'cppcheck', 'flawfinder'],
      \   'yaml': ['yamllint'],
      \   'cloudformation.yaml': ['cloudformation', 'yamllint'],
      \   'java': [''],
      \}

let g:ale_fixers = {
      \   '*': ['trim_whitespace'],
      \   'cpp': ['trim_whitespace'],
      \   'c': ['trim_whitespace'],
      \   'python': ['trim_whitespace', 'isort'],
      \   'json': ['fixjson', 'jq', 'trim_whitespace'],
      \   'yaml': ['trim_whitespace'],
      \   'sh': ['shfmt', 'trim_whitespace'],
      \   'go': ['goimports', 'gofmt', 'trim_whitespace'],
      \   'rust': ['rustfmt', 'trim_whitespace'],
      \   'ruby': ['rubocop', 'trim_whitespace'],
      \   'typescript': ['eslint', 'trim_whitespace'],
      \   'kotlin': ['ktlint', 'trim_whitespace'],
      \}

      ]]
end

return {
      {
            'w0rp/ale',
            init = configure_ale
      },
}
