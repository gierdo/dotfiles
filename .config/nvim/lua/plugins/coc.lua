local utils = require("utils")
return {
  {
    'neoclide/coc.nvim',
    branch = 'master',
    build = 'yarn install --frozen-lockfile',
    config = function()
      vim.g.coc_global_extensions = {
        'coc-css',
        'coc-html',
        'coc-java',
        'coc-json',
        'coc-lists',
        'coc-prettier',
        'coc-tsserver',
        'coc-snippets',
        'coc-vimtex',
        'coc-yaml',
        'coc-jedi',
        'coc-docker',
        'coc-diagnostic',
        'coc-xml',
        'coc-markdownlint',
        'coc-pyright',
        'coc-cfn-lint',
        'coc-kotlin',
        'coc-sumneko-lua',
      }
      utils.load_local_vimscript("plugins/coc.vim")
    end
  },
}
