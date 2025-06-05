return {
  {
    "airblade/vim-gitgutter",
  },
  {
    "tpope/vim-fugitive",
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup()
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
  },
  {
    "akinsho/git-conflict.nvim",
    config = true,
  },
}
