return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "cppdbg",
          "delve",
          "javadbg",
          "kotlin",
          "netcoredbg",
          "python",
        },
        handlers = {},
      })
    end,
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
  },
  {
    "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup({})

      -- add listeners to auto open DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      local wk = require("which-key")
      local telescope = require("telescope")

      wk.add({
        { "<leader>d", group = "  Debug" },
        {
          "<leader>dd",
          telescope.extensions.dap.commands,
          desc = "Show debug commands.",
        },
        {
          "<leader>dt",
          dap.toggle_breakpoint,
          desc = "Toggle line breakpoint on the current line.",
        },
        {
          "<leader>dbs",
          dap.set_breakpoint,
          desc = "Set breakpoint.",
        },
        {
          "<leader>dbl",
          telescope.extensions.dap.list_breakpoints,
          desc = "List breakpoints.",
        },
        {
          "<leader>dv",
          telescope.extensions.dap.variables,
          desc = "Show variables.",
        },
        {
          "<leader>dbc",
          dap.clear_breakpoints,
          desc = "Clear breakpoints.",
        },
        {
          "<leader>dbe",
          dap.set_exception_breakpoints,
          desc = "Set Exception breakpoints.",
        },
        {
          "<leader>dc",
          dap.continue,
          desc = "When debugging, continue. Otherwise start debugging.",
        },
        {
          "<leader>dfd",
          dap.down,
          desc = "Move down a frame in the current call stack.",
        },
        {
          "<leader>dfu",
          dap.up,
          desc = "Move up a frame in the current call stack.",
        },
        { "<leader>dp", dap.pause, desc = "Pause debuggee." },
        {
          "<leader>dr",
          dap.run_to_cursor,
          desc = "Continues execution to the current cursor.",
        },
        {
          "<leader>dre",
          dap.restart,
          desc = "Restart debugging with the same configuration.",
        },
      })
    end,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "folke/which-key.nvim",
    },
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
      "nvim-telescope/telescope.nvim",
    },
  },
}
