return {
  "harrisoncramer/gitlab.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "stevearc/dressing.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = {
    "GitLabReviewMR",
  },
  build = function()
    require("gitlab.server").build(true)
  end,
  config = function()
    require("gitlab").setup()

    vim.api.nvim_create_user_command("GitLabReviewMR", function()
      require("gitlab").choose_merge_request()
    end, {})
  end,
}
