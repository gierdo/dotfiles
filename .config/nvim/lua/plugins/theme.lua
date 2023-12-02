return {
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
    config = function()
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
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', opt = true }
    },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {}
      }
    end
  },
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
