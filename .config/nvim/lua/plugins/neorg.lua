return {
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*", -- Pin Neorg to the latest stable release
    config = function()
      local neorg = require("neorg")
      neorg.setup({
        load = {
          ["core.integrations.telescope"] = {},
          ["core.defaults"] = {},
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

      local wk = require("which-key")

      wk.add({
        { "<leader>n", group = "📚 Neorg" },
        { "<leader>nf", "<Plug>(neorg.telescope.find_norg_files)", desc = "Find norg files" },
        { "<leader>nl", "<Plug>(neorg.telescope.insert_link)", desc = "Insert link" },
        { "<leader>nw", "<Plug>(neorg.telescope.switch_workspace)", desc = "Switch workspace" },
        { "<leader>nr", "<Plug>(neorg.telescope.backlinks.file_backlinks)", desc = "Find file backlinks" },
        { "<leader>nd", "<Plug>(neorg.qol.todo-items.todo.task-done)", desc = "Done" },
        { "<leader>nu", "<Plug>(neorg.qol.todo-items.todo.task-undone)", desc = "Undone" },
        { "<leader>ni", "<Plug>(neorg.qol.todo-items.todo.task-important)", desc = "Important" },
        { "<leader>nc", "<Plug>(neorg.qol.todo-items.todo.task-cancelled)", desc = "Cancelled" },
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
