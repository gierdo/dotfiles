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
        profiles = {
          {
            name = "default",
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
          },
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
