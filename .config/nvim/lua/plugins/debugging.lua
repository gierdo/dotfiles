return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "cppdbg",
          "javadbg",
          "kotlin",
          "netcoredbg",
          "python",
          "node-debug2-adapter",
        },
        handlers = {},
      })

      -- Support vscode launch configurations
      -- external json decoder for support of (non-standard) trailing commas
      local dap_vscode = require("dap.ext.vscode")
      dap_vscode.json_decode = require("json5").parse
      dap_vscode.load_launchjs()
    end,
    dependencies = {
      "mason-org/mason.nvim",
      "mfussenegger/nvim-dap",
      {
        "Joakker/lua-json5",
        build = "./install.sh",
      },
    },
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
    dependencies = {
      "mfussenegger/nvim-dap",
      "jay-babu/mason-nvim-dap.nvim",
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

      local python_launch_with_arguments = {
        {
          type = "python",
          request = "launch",
          name = "Python: Launch file with arguments",
          program = "${file}",
          pythonPath = "python",
          args = function()
            local args_string = vim.fn.input("Arguments: ")
            return vim.split(args_string, " +")
          end,
          console = "integratedTerminal",
        },
      }
      vim.list_extend(dap.configurations["python"], python_launch_with_arguments)

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
        { "<leader>d", group = "   Debug" },
        {
          "<leader>dd",
          telescope.extensions.dap.commands,
          desc = "Show debug commands",
        },
        {
          "<leader>dt",
          dap.toggle_breakpoint,
          desc = "Toggle line breakpoint on the current line",
        },
        {
          "<leader>dbs",
          dap.set_breakpoint,
          desc = "Set breakpoint",
        },
        {
          "<leader>dbl",
          telescope.extensions.dap.list_breakpoints,
          desc = "List breakpoints",
        },
        {
          "<leader>dv",
          telescope.extensions.dap.variables,
          desc = "Show variables",
        },
        {
          "<leader>dbc",
          dap.clear_breakpoints,
          desc = "Clear breakpoints",
        },
        {
          "<leader>dbe",
          dap.set_exception_breakpoints,
          desc = "Set Exception breakpoints",
        },
        {
          "<leader>dc",
          dap.continue,
          desc = "When debugging, continue. Otherwise start debugging",
        },
        {
          "<leader>dfd",
          dap.down,
          desc = "Move down a frame in the current call stack",
        },
        {
          "<leader>dfu",
          dap.up,
          desc = "Move up a frame in the current call stack",
        },
        { "<leader>dp", dap.pause, desc = "Pause debuggee" },
        {
          "<leader>dr",
          dap.run_to_cursor,
          desc = "Continues execution to the current cursor",
        },
        {
          "<leader>dre",
          dap.restart,
          desc = "Restart debugging with the same configuration",
        },
      })
    end,
    dependencies = {
      "jay-babu/mason-nvim-dap.nvim",
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
