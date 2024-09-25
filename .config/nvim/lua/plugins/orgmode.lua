return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      local neorg = require("neorg")
      neorg.setup({
        load = {
          ["core.defaults"] = {},
          ["core.integrations.telescope"] = {},
          ["core.esupports.hop"] = {},
          ["core.concealer"] = {},
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp",
            },
          },
          ["core.keybinds"] = {
            config = {
              default_keybinds = false,
            },
            ["core.dirman"] = {
              config = {
                workspaces = {
                  notes = "~/Sync/notes",
                },
              },
            },
          },
        },
      })

      -- Unfold and conceal norg files
      vim.wo.foldlevel = 99
      vim.wo.conceallevel = 2

      local wk = require("which-key")

      wk.add({
        { "<leader>n", group = "📚 Neorg" },
        { "<leader>nf", "<Plug>(neorg.telescope.find_norg_files)", desc = "Find norg files" },
        { "<leader>nl", "<Plug>(neorg.telescope.insert_link)", desc = "Insert link" },
        { "<leader>nx", "<Plug>(neorg.esupports.hop.hop-link)", desc = "Hop to link" },
        { "<leader>nw", "<Plug>(neorg.telescope.switch_workspace)", desc = "Switch workspace" },
        { "<leader>nr", "<Plug>(neorg.telescope.backlinks.file_backlinks)", desc = "Find file backlinks" },
        { "<leader>nd", "<Plug>(neorg.qol.todo-items.todo.task-done)", desc = "Task done" },
        { "<leader>nu", "<Plug>(neorg.qol.todo-items.todo.task-undone)", desc = "Task undone" },
        { "<leader>ni", "<Plug>(neorg.qol.todo-items.todo.task-important)", desc = "Task important" },
        { "<leader>nc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", desc = "Task cancelled" },
        { "<leader>n<space>", "<Plug>(neorg.qol.todo-items.todo.task-cycle)", desc = "Cycle task state" },
      })
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-neorg/neorg-telescope",
      "folke/which-key.nvim",
    },
  },
}
