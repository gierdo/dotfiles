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
    config = function()
      local dap = require("dap")

      local dap_view = require("dap-view")
      dap_view.setup({
        winbar = {
          show = true,
          sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "sessions", "disassembly" },
          default_section = "breakpoints",
          base_sections = {
            breakpoints = {
              keymap = "B",
              label = " Breakpoints [B]",
              short_label = " [B]",
            },
            scopes = {
              keymap = "S",
              label = "󰂥 Scopes [S]",
              short_label = "󰂥 [S]",
            },
            exceptions = {
              keymap = "E",
              label = "󰢃 Exceptions [E]",
              short_label = "󰢃 [E]",
            },
            watches = {
              keymap = "W",
              label = "󰛐 Watches [W]",
              short_label = "󰛐 [W]",
            },
            threads = {
              keymap = "T",
              label = "󱉯 Threads [T]",
              short_label = "󱉯 [T]",
            },
            repl = {
              keymap = "R",
              label = "󰯃 REPL [R]",
              short_label = "󰯃 [R]",
            },
            sessions = {
              keymap = "K", -- I ran out of mnemonics
              label = "Sessions [K]",
              short_label = " [K]",
            },
            console = {
              keymap = "C",
              label = "󰆍 Console [C]",
              short_label = "󰆍 [C]",
            },
          },
          custom_sections = {},
          controls = {
            enabled = true,
            position = "right",
          },
        },
        windows = {
          height = 0.25,
          position = "below",
          terminal = {
            width = 0.3,
            position = "left",
            hide = { "go" },
            start_hidden = false,
          },
        },
        help = {
          border = nil,
        },
        switchbuf = "usetab",
        follow_tab = true,
        auto_toggle = true,
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
      "igorlfs/nvim-dap-view",
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
  {
    "Jorenar/nvim-dap-disasm",
    config = function()
      require("dap-disasm").setup({
        dapui_register = false,
        dapview_register = true,
        repl_commands = true,

        winbar = false,

        -- The sign to use for instruction the exectution is stopped at
        sign = "DapStopped",

        -- Number of instructions to show before the memory reference
        ins_before_memref = 16,

        -- Number of instructions to show after the memory reference
        ins_after_memref = 16,

        -- Labels of buttons in winbar
        controls = {
          step_into = "Step Into",
          step_over = "Step Over",
          step_back = "Step Back",
        },

        -- Columns to display in the disassembly view
        columns = {
          "address",
          "instructionBytes",
          "instruction",
        },
      })
    end,
    dependencies = {
      "mfussenegger/nvim-dap",
      "igorlfs/nvim-dap-view",
    },
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    config = function()
      require("persistent-breakpoints").setup({
        save_dir = vim.fn.stdpath("data") .. "/nvim_checkpoints",
        -- when to load the breakpoints? "BufReadPost" is recommanded.
        load_breakpoints_event = nil,
        -- record the performance of different function. run :lua require('persistent-breakpoints.api').print_perf_data() to see the result.
        perf_record = false,
        -- perform callback when loading a persisted breakpoint
        --- @param opts DAPBreakpointOptions options used to create the breakpoint ({condition, logMessage, hitCondition})
        --- @param buf_id integer the buffer the breakpoint was set on
        --- @param line integer the line the breakpoint was set on
        on_load_breakpoint = nil,
        -- set this to true if the breakpoints are not loaded when you are using a session-like plugin.
        always_reload = false,
      })
    end,
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  {
    "Carcuis/dap-breakpoints.nvim",
    config = function()
      require("dap-breakpoints").setup()

      local dapbp_api = require("dap-breakpoints.api")
      local dapbp_keymaps = {
        { "<leader>dbt", dapbp_api.toggle_breakpoint, desc = "Toggle Breakpoint" },
        { "<leader>dbs", dapbp_api.set_breakpoint, desc = "Set Breakpoint" },
        { "<leader>dbc", dapbp_api.set_conditional_breakpoint, desc = "Set Conditional Breakpoint" },
        { "<leader>dbh", dapbp_api.set_hit_condition_breakpoint, desc = "Set Hit Condition Breakpoint" },
        { "<leader>dbl", dapbp_api.set_log_point, desc = "Set Log Point" },
        {
          "<leader>dbL",
          function()
            dapbp_api.load_breakpoints({
              notify = "always", ---@type "always" | "never" | "on_empty" | "on_some"
            })
          end,
          desc = "Load Breakpoints",
        },
        {
          "<leader>dbS",
          function()
            dapbp_api.save_breakpoints({
              notify = "always", ---@type "always" | "never" | "on_empty" | "on_some"
            })
          end,
          desc = "Save Breakpoints",
        },
        { "<leader>dbe", dapbp_api.edit_property, desc = "Edit Breakpoint Property" },
        {
          "<leader>dbE",
          function()
            dapbp_api.edit_property({ all = true })
          end,
          desc = "Edit All Breakpoint Properties",
        },
        { "<leader>dbv", dapbp_api.toggle_virtual_text, desc = "Toggle Breakpoint Virtual Text" },
        { "<leader>dbC", dapbp_api.clear_all_breakpoints, desc = "Clear All Breakpoints" },
      }
      for _, keymap in ipairs(dapbp_keymaps) do
        vim.keymap.set("n", keymap[1], keymap[2], { desc = keymap.desc })
      end
    end,
    dependencies = {
      "Weissle/persistent-breakpoints.nvim",
      "mfussenegger/nvim-dap",
    },
  },
}
