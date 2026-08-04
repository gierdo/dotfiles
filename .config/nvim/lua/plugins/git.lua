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
    init = function()
      vim.api.nvim_create_autocmd("User", {
        -- lensline distorts vertical space by adding virtual line breaks, which fuddles up vertical sync in the diff
        pattern = "CodeDiffOpen",
        callback = function()
          local ok, lensline = pcall(require, "lensline")
          if ok then
            lensline.hide()
          end
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        pattern = "CodeDiffClose",
        callback = function()
          local ok, lensline = pcall(require, "lensline")
          if ok then
            lensline.show()
          end
        end,
      })
    end,
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
      highlights = {
        line_insert = "#2b3d32",
        line_delete = "#4a3536",
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
    "emrearmagan/atlas.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "MeanderingProgrammer/render-markdown.nvim",
      -- "esmuellert/codediff.nvim",
    },
    opts = {
      pulls = {
        diff = {
          -- Any command that accepts explicit <base>...<head> Git revisions.
          open_cmd = "AtlasDiff", -- default; for example "DiffviewOpen" or "CodeDiff".

          -- AtlasDiff options; external viewers use their own configuration.
          layout = "side-by-side", -- "inline" or "side-by-side".
          compact = true, -- Start with only changed hunks and surrounding context visible.
          explorer = {
            grouped = true, -- Group changed files by directory.
            hidden = false,
            show_commits = true, -- Initially show commits below changed files.
            width = 40,
            initial_focus = "explorer", -- "explorer" or "diff".
            ignore = { ".git/**", ".jj/**" },
          },
        },
        providers = {
          gitlab = {
            base_url = vim.env.GITLAB_URL or "https://gitlab.com",
            token = vim.env.GITLAB_TOKEN,
            cache_ttl = 300,

            ---@type AtlasGitLabPullsViewConfig[]
            views = {
              {
                name = "Assigned",
                key = "1",
                scope = "assigned_to_me",
              },
              {
                name = "Reviewing",
                key = "3",
                scope = "all",
                extra_params = { reviewer_username = vim.env.GITLAB_USERNAME },
              },
              -- Single project
              {
                name = "GitLab",
                key = "G",
                project = "gitlab-org/gitlab",
              },
              -- Whole group, all projects under it
              {
                name = "GitLab Org",
                key = "O",
                group = "gitlab-org",
              },
            },

            bookmarks = {
              key = "S", -- default
              label = "Search", -- default
              items = {
                ["Reviewing"] = { scope = "all", extra_params = { reviewer_username = vim.env.GITLAB_USERNAME } },
                ["Merged by me"] = { scope = "all", state = "merged", author_username = vim.env.GITLAB_USERNAME },
              },
            },
          },
        },
      },
      issues = {
        providers = {
          gitlab = {
            base_url = vim.env.GITLAB_URL or "https://gitlab.com",
            token = vim.env.GITLAB_TOKEN,
            cache_ttl = 300,

            ---@type AtlasGitLabIssuesViewConfig[]
            views = {
              {
                name = "Assigned",
                key = "1",
                scope = "assigned_to_me",
                state = "opened",
              },
              {
                name = "Created",
                key = "2",
                scope = "created_by_me",
                state = "opened",
              },
              {
                name = "All open",
                key = "3",
                scope = "all",
                state = "opened",
                -- Anything not covered by the explicit fields below can be passed via `extra_params`.
                extra_params = { ["not[labels]"] = "wontfix" },
              },
            },

            bookmarks = {
              key = "S", -- default
              label = "Search", -- default
              items = {
                ["No labels"] = {
                  scope = "all",
                  state = "opened",
                  extra_params = { ["not[labels]"] = "*" },
                },
                ["Closed"] = { scope = "created_by_me", state = "closed" },
              },
            },
          },
        },
      },
    },
  },
}
