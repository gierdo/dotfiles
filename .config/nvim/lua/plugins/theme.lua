return {
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = 'dark' -- or 'light'
      require('solarized').setup({
        transparent = false,
        styles = {
          comments = {},
          functions = {},
          variables = {},
          numbers = {},
          constants = {},
          parameters = {},
          keywords = {},
          types = { bold = true },
        },
        enables = {
          bufferline = true,
          cmp = true,
          diagnostic = false,
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
        highlights = function(colors, colorhelper)
          return {
            NvimTreeWinSeparator = { link = 'WinSeparator' }, -- Use normal window separator lines for nvim tree
            CocUnusedHighlight = { link = 'DiagnosticHint' }, -- Change background of diagnostic-info-sections
          }
        end,
        colors = {},
        theme = 'default', -- or 'neosolarized' or 'neo' for short
      })
      vim.cmd.colorscheme('solarized')
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' }
    },
    enabled = function()
      return vim.g.started_by_firenvim ~= true
    end,
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
        extensions = {
          'quickfix',
          'nvim-tree'
        }
      }
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      local highlight = {
        "Whitespace",
        "CursorColumn",
      }
      require("ibl").setup {
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      }
    end
  },
  'mkitt/tabline.vim',
}
