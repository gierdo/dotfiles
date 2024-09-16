return {
  {
    "nvim-neotest/neotest",
    event = "VeryLazy",
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-python"),

          require("neotest-jest")({
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),
          require("neotest-vim-test")({ ignore_filetypes = { "python", "java", "typescript", "javascript" } }),
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
            neotest.run.run({ strategy = "dap" })
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
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "rcasia/neotest-java",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-vim-test",
      "weilbith/neotest-gradle",
      "folke/which-key.nvim",
      "mfussenegger/nvim-dap",
      "williamboman/mason-lspconfig.nvim", -- the java lsp configuration breaks kotlin test system precedency
    },
  },
  { "antoinemadec/FixCursorHold.nvim", lazy = true },
  { "nvim-neotest/neotest-python", lazy = true },
  { "rcasia/neotest-java", lazy = true },
  { "nvim-neotest/neotest-jest", lazy = true },
  { "nvim-neotest/neotest-vim-test", lazy = true },
  { "vim-test/vim-test", lazy = true },
  { "weilbith/neotest-gradle", lazy = true },
  { "nvim-neotest/nvim-nio" },
}
