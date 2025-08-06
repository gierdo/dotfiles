return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    config = function()
      require("mason-nvim-dap").setup({ ---@diagnostic disable-line: missing-fields
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
      dap_vscode.getconfigs()
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
    event = "VeryLazy",
  },
  {
    "igorlfs/nvim-dap-view",
    event = "VeryLazy",
    config = function()
      local dap = require("dap")

      local views = require("dap-view.views")
      local dap_view = require("dap-view")
      dap_view.setup({
        winbar = {
          show = true,
          sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl" },
          default_section = "breakpoints",
          base_sections = {
            breakpoints = {
              keymap = "B",
              label = "Breakpoints [B]",
              short_label = " [B]",
              action = function()
                views.switch_to_view("breakpoints")
              end,
            },
            scopes = {
              keymap = "S",
              label = "Scopes [S]",
              short_label = "󰂥 [S]",
              action = function()
                views.switch_to_view("scopes")
              end,
            },
            exceptions = {
              keymap = "E",
              label = "Exceptions [E]",
              short_label = "󰢃 [E]",
              action = function()
                views.switch_to_view("exceptions")
              end,
            },
            watches = {
              keymap = "W",
              label = "Watches [W]",
              short_label = "󰛐 [W]",
              action = function()
                views.switch_to_view("watches")
              end,
            },
            threads = {
              keymap = "T",
              label = "Threads [T]",
              short_label = "󱉯 [T]",
              action = function()
                views.switch_to_view("threads")
              end,
            },
            repl = {
              keymap = "R",
              label = "REPL [R]",
              short_label = "󰯃 [R]",
              action = function()
                require("dap-view.repl").show()
              end,
            },
            console = {
              keymap = "C",
              label = "Console [C]",
              short_label = "󰆍 [C]",
              action = function()
                require("dap-view.term").show()
              end,
            },
          },
          custom_sections = {},
          controls = {
            enabled = true,
            position = "right",
            buttons = {
              "play",
              "step_into",
              "step_over",
              "step_out",
              "step_back",
              "run_last",
              "terminate",
              "disconnect",
            },
            icons = {
              play = "",
              pause = "",
              step_into = "",
              step_over = "",
              step_out = "",
              step_back = "",
              run_last = "",
              terminate = "",
              disconnect = "",
            },
            custom_buttons = {},
          },
        },
        windows = {
          height = 0.25,
          position = "below",
          terminal = {
            width = 0.5,
            position = "left",
            hide = {},
            start_hidden = false,
          },
        },
        help = {
          border = nil,
        },
        switchbuf = "usetab",
        auto_toggle = false,
      }) ---@diagnostic disable-line: missing-fields

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
        dap_view.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dap_view.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dap_view.close()
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
    event = "VeryLazy",
    config = function()
      require("nvim-dap-virtual-text").setup() ---@diagnostic disable-line: missing-parameter
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "mfussenegger/nvim-dap",
      "nvim-telescope/telescope.nvim",
    },
  },
}
