local sonarlint_flietypes = { "java", "python" }

return {
  {
    "https://gitlab.com/schrieveslaach/sonarlint.nvim",
    ft = sonarlint_flietypes,
    config = function()
      require("sonarlint").setup({
        server = {
          cmd = vim
            .iter({
              "java",
              "-jar",
              vim.fn.expand("$MASON/packages/sonarlint-language-server/extension/server/sonarlint-ls.jar"),
              "-stdio",
              "-analyzers",
              vim.fn.expand("$MASON/share/sonarlint-analyzers/*.jar", true, 1),
            })
            :flatten()
            :totable(),
        },
        filetypes = sonarlint_flietypes,
      })
    end,
  },
}
