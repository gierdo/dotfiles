return {
  'airblade/vim-gitgutter',
  'tpope/vim-fugitive',
  {
    'sindrets/diffview.nvim',
    event = 'VeryLazy',
    config = function()
      require("diffview").setup()
    end,
  },
  {
    "NeogitOrg/neogit",
    event = 'VeryLazy',
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "sindrets/diffview.nvim",        -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true
  }
}
