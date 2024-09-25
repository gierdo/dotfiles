return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = { "~/Sync/org/**/*", "~/org/**/*" },
        org_default_notes_file = "~/Sync/org/refile.org",
        mappings = {
          org = {
            org_insert_link = false,
            org_refile = false,
          },
        },
      })

      local wk = require("which-key")
      wk.add({
        { "<leader>n", group = "📚 org roam" },
      })

      wk.add({
        { "<leader>o", group = "📚 org" },
      })
      vim.opt.conceallevel = 2
      vim.opt.concealcursor = "nc"
    end,
  },
  {
    "akinsho/org-bullets.nvim",
    config = function()
      require("org-bullets").setup()
    end,
    dependencies = {
      "nvim-orgmode/orgmode",
    },
  },
  {
    "chipsenkbeil/org-roam.nvim",
    tag = "0.1.0",
    dependencies = {
      {
        "nvim-orgmode/orgmode",
        tag = "0.3.4",
      },
    },
    config = function()
      require("org-roam").setup({
        directory = "~/Sync/org/roam",
        -- optional
        -- org_files = {
        --   "~/another_org_dir",
        --   "~/some/folder/*.org",
        --   "~/a/single/org_file.org",
        -- },
      })
    end,
  },
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    event = "VeryLazy",
    config = function()
      require("telescope").load_extension("orgmode")

      vim.keymap.set(
        "n",
        "<leader>or",
        require("telescope").extensions.orgmode.refile_heading,
        { desc = "Refile heading" }
      )
      vim.keymap.set(
        "n",
        "<leader>oh",
        require("telescope").extensions.orgmode.search_headings,
        { desc = "Search headings" }
      )
    end,
    dependencies = {
      "nvim-orgmode/orgmode",
      "nvim-telescope/telescope.nvim",
    },
  },
}
