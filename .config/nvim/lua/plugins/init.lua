return {
  { "nvim-lua/plenary.nvim", lazy = true }, -- lua base library
  {
    "scrooloose/nerdcommenter",
    event = "VeryLazy",
    config = function()
      vim.g.NERDDefaultAlign = "left"
      vim.g.NERDCompactSexyComs = 0
      vim.g.NERDSpaceDelims = 1
      vim.cmd([[
			let g:NERDCustomDelimiters = {
				\ 'c': { 'left': '/*','right': '*/' },
				\ 'debsources': { 'left': '#'},
				\ 'cmake': { 'left': '#'}
				\}
			]])
    end,
  },
  "tpope/vim-sleuth",
  {
    "cappyzawa/trim.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "RaafatTurki/hex.nvim",
    event = "VeryLazy",
    config = function()
      require("hex").setup()
    end,
  },
  {
    "honza/vim-snippets",
    event = "VeryLazy",
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    config = function()
      local npairs = require("nvim-autopairs")

      npairs.setup({
        map_cr = false,
        check_ts = true,
      })
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "justinmk/vim-gtfo",
    event = "VeryLazy",
  },
  {
    "powerman/vim-plugin-AnsiEsc",
  },
  {
    "JMarkin/gentags.lua",
    cond = vim.fn.executable("ctags") == 1,
    event = "VeryLazy",
    config = function()
      require("gentags").setup({})
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "liuchengxu/vista.vim",
    config = function()
      vim.cmd("nmap <silent> <F8> :Vista!!<CR>")
    end,
  },
  {
    "dhruvasagar/vim-table-mode",
    event = "VeryLazy",
    config = function()
      -- Delete keymap to not conflict with test keymaps
      vim.keymap.del({ "n", "x" }, "<leader>tt")
    end,
  },
  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "junegunn/fzf",
    },
  },
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_syntax_enabled = 0
      if vim.fn.executable("zathura") == 1 then
        vim.g.vimtex_view_method = "zathura"
      end
    end,
  },
  {
    "fatih/vim-go",
    build = ":GoUpdateBinaries",
  },
  {
    "jamessan/vim-gnupg",
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "GnuPG",
        command = "setlocal textwidth=72",
      })
    end,
  },
  {
    "aklt/plantuml-syntax",
  },
  {
    "tyru/open-browser.vim",
    lazy = true,
    config = function()
      vim.cmd([[
			let g:openbrowser_browser_commands = [
				\ {"name": "firefox",
				\  "args": ["{browser}", "{uri}"]},
				\ {"name": "xdg-open",
				\  "args": ["{browser}", "{uri}"]},
				\ {"name": "x-www-browser",
				\  "args": ["{browser}", "{uri}"]},
				\ {"name": "w3m",
				\  "args": ["{browser}", "{uri}"]},
				\ ]
			]])
    end,
  },
  {
    "weirongxu/plantuml-previewer.vim",
    cmd = { "PlantumlOpen", "PlantumlToggle", "PlantumlStart" },
    dependencies = {
      "tyru/open-browser.vim",
    },
    config = function()
      vim.g.plantuml_previewer_plantuml_jar_path = vim.env.HOME .. ".local/share/plantuml/plantuml.jar"
    end,
  },
  {
    "preservim/vim-markdown",
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_auto_insert_bullets = 0
      vim.g.vim_markdown_new_list_item_indent = 0
    end,
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_browser = "firefox"
      vim.g.mkdp_auto_close = 0
    end,
    ft = { "markdown" },
  },
}
