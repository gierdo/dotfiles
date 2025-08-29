return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({ current_line_blame = true })
    end,
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        use_icons = true,
      })

      local function set_diff_highlights()
        local is_dark = vim.o.background == "dark"

        if is_dark then
          vim.api.nvim_set_hl(0, "DiffAdd", { fg = "none", bg = "#2e4b2e", bold = true })
          vim.api.nvim_set_hl(0, "DiffDelete", { fg = "none", bg = "#4c1e15", bold = true })
          vim.api.nvim_set_hl(0, "DiffChange", { fg = "none", bg = "#45565c", bold = true })
          vim.api.nvim_set_hl(0, "DiffText", { fg = "none", bg = "#996d74", bold = true })
        else
          vim.api.nvim_set_hl(0, "DiffAdd", { fg = "none", bg = "palegreen", bold = true })
          vim.api.nvim_set_hl(0, "DiffDelete", { fg = "none", bg = "tomato", bold = true })
          vim.api.nvim_set_hl(0, "DiffChange", { fg = "none", bg = "lightblue", bold = true })
          vim.api.nvim_set_hl(0, "DiffText", { fg = "none", bg = "lightpink", bold = true })
        end
      end

      set_diff_highlights()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("DiffColors", { clear = true }),
        callback = set_diff_highlights,
      })
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
  },
  {
    "akinsho/git-conflict.nvim",
    config = true,
  },
  {
    "oribarilan/lensline.nvim",
    brnach = "release/1.x",
    event = "LspAttach",
    config = function()
      require("lensline").setup({
        providers = {
          {
            name = "references",
            enabled = true,
            quiet_lsp = true,
          },
          {
            name = "last_author",
            enabled = true,
            cache_max_files = 50,
          },

          {
            name = "diagnostics",
            enabled = true,
            min_level = "WARN",
          },
          {
            name = "complexity",
            enabled = true,
            min_level = "L",
          },
        },
        style = {
          separator = " • ",
          highlight = "Comment",
          prefix = "┃ ",
          use_nerdfont = true,
        },
        limits = {
          exclude = {},
          exclude_gitignored = true,
          max_lines = 1000,
          max_lenses = 70,
        },
        debounce_ms = 500,
        debug_mode = false,
      })
    end,
  },
}
