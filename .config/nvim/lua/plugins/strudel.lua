return {
  {
    "gruvw/strudel.nvim",
    build = "npm ci",
    config = function()
      require("strudel").setup()
    end,
  },
}
