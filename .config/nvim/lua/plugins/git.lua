return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({ current_line_blame = true })
    end,
  },
  {
    "esmuellert/codediff.nvim",
    cmd = "CodeDiff",
    keys = {
      { "<leader>gv", "<cmd>CodeDiff<CR>", desc = "Open CodeDiff" },
      { "<leader>gc", "<cmd>tabclose<CR>", desc = "Close CodeDiff" },
      { "<leader>gf", "<cmd>CodeDiff history<CR>", desc = "File history" },
    },
    opts = {
      diff = {
        layout = "side-by-side",
        disable_inlay_hints = true,
      },
    },
  },
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require("blame").setup({})
    end,
    opts = {
      blame_options = { "-w" },
    },
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "esmuellert/codediff.nvim", -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
  },
  {
    "akinsho/git-conflict.nvim",
    config = {
      disable_diagnostics = true,
    },
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
