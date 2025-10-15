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
  {
    "harrisoncramer/gitlab.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    build = function()
      require("gitlab.server").build(true)
    end, -- Builds the Go binary
    config = function()
      local gitlab = require("gitlab")
      gitlab.setup()

      vim.api.nvim_create_user_command("GitLabChooseMR", function()
        gitlab.choose_merge_request()
      end, {
        desc = "Choose open GitLab merge request for local review",
      })
      vim.api.nvim_create_user_command("GitLabReviewMR", function()
        gitlab.review()
      end, {
        desc = "Open merge request for current branch for local review",
      })
    end,
  },
}
