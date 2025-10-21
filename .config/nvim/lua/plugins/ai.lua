return {
  "folke/sidekick.nvim",
  config = function()
    sidekick = require("sidekick")
    sidekick.setup({
      nes = {
        enabled = false,
      },
      cli = {
        enabled = true,
        mux = {
          backend = "tmux",
          enabled = true,
        },
      },
    })
  end,
  cmd = {
    "Sidekick",
  },
  keys = {
    {
      "<A-a>",
      function()
        require("sidekick.cli").toggle({ filter = { installed = true } })
      end,
      desc = "Sidekick Toggle",
      mode = { "n", "t", "i" },
    },
    {
      "<A-a>",
      function()
        require("sidekick.cli").send({
          filter = { installed = true },
          msg = "The current file is {file}, this is the current selection: \n\n```\n{selection}\n```",
        })
      end,
      desc = "Sidekick Toggle with context",
      mode = { "x" },
    },
    {
      "<A-i>",
      function()
        require("sidekick.cli").prompt({ filter = { installed = true } })
      end,
      desc = "Sidekick Select Prompt",
      mode = { "n", "t", "i", "x" },
    },
  },
}
