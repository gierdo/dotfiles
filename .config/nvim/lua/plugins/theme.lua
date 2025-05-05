return {
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark" -- or 'light'
      require("solarized").setup({
        transparent = {
          enabled = true,
          pmenu = false,
          normal = false,
          normalfloat = false,
          neotree = true,
          nvimtree = true,
          whichkey = true,
          telescope = true,
          lazy = false,
        },
        on_highlights = function(colors, color)
          ---@type solarized.highlights
          local groups = {
            NvimTreeWinSeparator = { link = "WinSeparator" }, -- Use normal window separator lines for nvim tree
            CocUnusedHighlight = { link = "DiagnosticHint" }, -- Change background of diagnostic-info-sections
            SpellBad = { strikethrough = false }, -- Solarized dark defaults to striking through wrong spelling
          }
          return groups
        end,
        on_colors = nil,
        palette = "solarized", -- solarized (default) | selenized
        styles = {
          types = { bold = true },
          functions = {},
          parameters = {},
          comments = {},
          strings = {},
          keywords = {},
          variables = {},
          constants = {},
        },
        plugins = {
          treesitter = true,
          lspconfig = true,
          navic = true,
          cmp = true,
          indentblankline = true,
          neotree = true,
          nvimtree = true,
          whichkey = true,
          dashboard = true,
          gitsigns = true,
          telescope = true,
          noice = true,
          hop = true,
          ministatusline = true,
          minitabline = true,
          ministarter = true,
          minicursorword = true,
          notify = true,
          rainbowdelimiters = true,
          bufferline = true,
          lazy = true,
          rendermarkdown = true,
          ale = true,
          coc = true,
          leap = true,
          alpha = true,
          yanky = true,
          gitgutter = true,
        },
      })
      vim.cmd.colorscheme("solarized")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
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
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {
          "quickfix",
          "nvim-tree",
        },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    opts = {},
    config = function()
      local highlight = {
        "Whitespace",
        "CursorColumn",
      }
      require("ibl").setup({
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      })
    end,
  },
  "mkitt/tabline.vim",
  {
    "stevearc/dressing.nvim",
    config = true,
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
    },
  },
  "rcarriga/nvim-notify",
}
