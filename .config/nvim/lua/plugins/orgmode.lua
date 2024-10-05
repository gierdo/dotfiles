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
        org_capture_templates = {
          t = {
            description = "Task",
            headline = "Todos",
            template = "* TODO %?\n  %u",
            target = "~/Sync/org/todos.org",
          },
          b = {
            description = "Bookmark",
            headline = "Bookmarks",
            template = "** [[%?]] \n:PROPERTIES:\n:CREATED: %U\n:END:",
            properties = {
              empty_lines = 1,
            },
            target = "~/Sync/org/bookmarks.org",
          },
          n = {
            description = "Unordered Note",
            template = "* %?\n  %u",
            properties = {
              empty_lines = 1,
            },
          },
        },
        mappings = {
          org = {
            org_insert_link = false,
            org_refile = false,
          },
        },
      })

      local orgHyperlink = require("orgmode.org.links.hyperlink")
      local function copy_at_point()
        local link = orgHyperlink.at_cursor()
        if not link then
          vim.fn.setreg("+", "")
        end
        vim.fn.setreg("+", link.url:to_string())
      end

      local wk = require("which-key")
      wk.add({
        { "<leader>n", group = "📚 org roam" },
      })

      wk.add({
        { "<leader>o", group = "📚 org" },
        {
          "<leader>ol",
          copy_at_point,
          desc = "Copy link into register",
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "org",
        command = "setlocal concealcursor=nc conceallevel=2",
      })
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
      },
    },
    config = function()
      require("org-roam").setup({
        directory = "~/Sync/org/roam",
        org_files = {
          "~/Sync/org/*.org",
        },
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
