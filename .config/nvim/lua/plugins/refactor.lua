return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require('refactoring').setup({
        prompt_func_return_type = {
          go = false,
          java = false,

          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        prompt_func_param_type = {
          go = false,
          java = false,

          cpp = false,
          c = false,
          h = false,
          hpp = false,
          cxx = false,
        },
        printf_statements = {},
        print_var_statements = {},
      })
      -- load refactoring Telescope extension
      require("telescope").load_extension("refactoring")

      vim.keymap.set(
        { "n", "x" },
        "<leader>rr",
        function() require('telescope').extensions.refactoring.refactors() end
      )
    end,
  },
}
