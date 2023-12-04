return {
  {
    "nvim-neotest/neotest",
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python"),

          require('neotest-jest')({
            env = { CI = true },
            cwd = function(path)
              return vim.fn.getcwd()
            end,
          }),

          require("neotest-java")({
            ignore_wrapper = false, -- whether to ignore maven/gradle wrapper
          }),

          require("neotest-vim-test")({ ignore_filetypes = { "python", "java", "typescript", "javascript" } }),
        },
      })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "rcasia/neotest-java",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-vim-test",
    }
  },
  "antoinemadec/FixCursorHold.nvim",
  "nvim-neotest/neotest-python",
  "rcasia/neotest-java",
  "nvim-neotest/neotest-jest",
  "nvim-neotest/neotest-vim-test",
  "vim-test/vim-test",
}
