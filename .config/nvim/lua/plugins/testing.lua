return {
  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-python"),
          require("neotest-dotnet"),
          require("neotest-golang")({
            testify_enabled = true,
            dap_go_opts = {
              delve = {
                -- the path to the executable dlv which will be used for debugging.
                -- by default, this is the "dlv" executable on your PATH.
                path = "dlv",
                -- time to wait for delve to initialize the debug session.
                -- default to 20 seconds
                initialize_timeout_sec = 20,
                -- a string that defines the port to start delve debugger.
                -- default to string "${port}" which instructs nvim-dap
                -- to start the process in a random available port.
                -- if you set a port in your debug configuration, its value will be
                -- assigned dynamically.
                port = "${port}",
                -- additional args to pass to dlv
                args = {},
                -- the build flags that are passed to delve.
                -- defaults to empty string, but can be used to provide flags
                -- such as "-tags=unit" to make sure the test suite is
                -- compiled during debugging, for example.
                -- passing build flags using args is ineffective, as those are
                -- ignored by delve in dap mode.
                -- avaliable ui interactive function to prompt for arguments get_arguments
                build_flags = {},
                -- whether the dlv process to be created detached or not. there is
                -- an issue on Windows where this needs to be set to false
                -- otherwise the dlv server creation will fail.
                -- avaliable ui interactive function to prompt for build flags: get_build_flags
                detached = vim.fn.has("win32") == 0,
                -- the current working directory to run dlv from, if other than
                -- the current working directory.
                cwd = nil,
              },
              -- options related to running closest test
              tests = {
                -- enables verbosity when running the test.
                verbose = false,
              },
            },
          }),

          require("neotest-jest")({
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),

          require("neotest-vim-test")({ ignore_filetypes = { "python", "java", "typescript", "javascript", "go" } }),
          require("neotest-gradle"),
          require("neotest-java")({
            ignore_filetypes = { "kotlin" },
            ignore_wrapper = false, -- whether to ignore maven/gradle wrapper
          }),
        },
      })

      local wk = require("which-key")

      wk.add({
        { "<leader>t", group = "   Test" },
        { "<leader>tr", neotest.run.run, desc = "Run nearest test." },
        {
          "<leader>tf",
          function()
            neotest.run.run(vim.fn.expand("%"))
          end,
          desc = "Run current file.",
        },
        {
          "<leader>td",
          function()
            neotest.run.run({ suite = false, strategy = "dap" })
          end,
          desc = "Debug nearest test.",
        },
        {
          "<leader>ts",
          neotest.summary.toggle,
          desc = "Show/hide summary.",
        },
      })
    end,
    dependencies = {
      {
        "fredrikaverpil/neotest-golang",
        dependencies = {
          "leoluz/nvim-dap-go",
        },
      },
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "rcasia/neotest-java",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-vim-test",
      "Issafalcon/neotest-dotnet",
      "weilbith/neotest-gradle",
      "folke/which-key.nvim",
      "mfussenegger/nvim-dap",
      "williamboman/mason-lspconfig.nvim", -- the java lsp configuration breaks kotlin test system precedency
    },
  },
}
