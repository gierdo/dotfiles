local function configure_theme()
  vim.o.background = 'dark' -- or 'light'
  require('solarized').setup({
    transparent = false,    -- enable transparent background
    styles = {
      comments = {},
      functions = {},
      variables = {},
      numbers = {},
      constants = {},
      parameters = {},
      keywords = {},
      types = {},
    },
    enables = {
      bufferline = true,
      cmp = true,
      diagnostic = true,
      dashboard = true,
      editor = true,
      gitsign = true,
      hop = true,
      indentblankline = true,
      lsp = true,
      lspsaga = true,
      navic = true,
      neogit = true,
      neotree = true,
      notify = true,
      semantic = true,
      syntax = true,
      telescope = true,
      tree = true,
      treesitter = true,
      whichkey = true,
      mini = true,
    },
    highlights = {},
    colors = {},
    theme = 'default', -- or 'neosolarized' or 'neo' for short
  })
  vim.cmd.colorscheme 'solarized'
end

return {
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
    config = configure_theme
  },
  {
    lazy = false,
    priority = 1000,
    'vim-airline/vim-airline',
    dependencies = {
      'vim-airline/vim-airline-themes'
    },
    init = function()
      vim.g.airline_theme = 'atomic'
      vim.g.airline_powerline_fonts = 1
    end
  },
  'vim-airline/vim-airline-themes',
  {
    'preservim/vim-indent-guides',
    init = function()
      vim.g.indent_guides_enable_on_vim_startup = 1
      vim.g.indent_guides_start_level = 2
      vim.g.indent_guides_guide_size = 1
      vim.g.indent_guides_exclude_filetypes = { 'nerdtree', 'help' }
      vim.g.indent_guides_auto_colors = 1
    end
  },
}
