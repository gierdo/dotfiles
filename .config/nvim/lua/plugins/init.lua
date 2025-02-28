return {
  { "nvim-lua/plenary.nvim", lazy = true }, -- lua base library
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300

      local wk = require("which-key")
      ---@class wk.Opts
      local options = {
        sort = { "group", "local", "order", "manual", "mod" },
      }
      wk.setup(options)
    end,
  },
  {},
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
    "RaafatTurki/hex.nvim",
    event = "VeryLazy",
    config = function()
      require("hex").setup()
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
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
    "dhruvasagar/vim-table-mode",
    event = "VeryLazy",
    config = function()
      -- Delete keymap to not conflict with test keymaps
      vim.keymap.del({ "n", "x" }, "<leader>tt")
      vim.keymap.del({ "n" }, "<leader>tm")
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
    cmd = {
      "PlantumlOpen",
      "PlantumlToggle",
      "PlantumlStart",
      "PlantumlSave",
    },
    dependencies = {
      "tyru/open-browser.vim",
    },
    config = function()
      vim.cmd([[
        let g:plantuml_previewer#plantuml_jar_path = $HOME."/.local/share/plantuml/plantuml.jar"
      ]])
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
    config = function()
      os.execute("systemctl --user start plantuml")
      vim.cmd([[
      let g:mkdp_auto_close = 0
      let g:mkdp_filetypes = ['markdown']
      let g:mkdp_preview_options = {
        \ 'mkit': {},
        \ 'katex': {},
        \ 'uml': { 'server': 'http://localhost:9742',  'imageFormat': 'svg' },
        \ 'maid': {},
        \ 'disable_sync_scroll': 0,
        \ 'sync_scroll_type': 'middle',
        \ 'hide_yaml_meta': 1,
        \ 'sequence_diagrams': {},
        \ 'flowchart_diagrams': {},
        \ 'content_editable': v:false,
        \ 'disable_filename': 0,
        \ 'toc': {}
        \ }
        ]])
    end,
    ft = { "markdown" },
  },
  {
    "monaqa/dial.nvim",
    config = function()
      local dial_map = require("dial.map")
      vim.keymap.set("n", "<C-a>", function()
        dial_map.manipulate("increment", "normal")
      end)
      vim.keymap.set("n", "<C-x>", function()
        dial_map.manipulate("decrement", "normal")
      end)
      vim.keymap.set("n", "g<C-a>", function()
        dial_map.manipulate("increment", "gnormal")
      end)
      vim.keymap.set("n", "g<C-x>", function()
        dial_map.manipulate("decrement", "gnormal")
      end)
      vim.keymap.set("v", "<C-a>", function()
        dial_map.manipulate("increment", "visual")
      end)
      vim.keymap.set("v", "<C-x>", function()
        dial_map.manipulate("decrement", "visual")
      end)
      vim.keymap.set("v", "g<C-a>", function()
        dial_map.manipulate("increment", "gvisual")
      end)
      vim.keymap.set("v", "g<C-x>", function()
        dial_map.manipulate("decrement", "gvisual")
      end)
    end,
  },
  {
    "rest-nvim/rest.nvim",
  },
  {
    "stevearc/overseer.nvim",
    event = "VeryLazy",
    config = function()
      local overseer = require("overseer")
      overseer.setup()

      vim.keymap.set("n", "<A-r>", function()
        vim.cmd("OverseerRun")
      end, { desc = "Run Tasks" })
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "stevearc/dressing.nvim",
      "rcarriga/nvim-notify",
    },
  },
  { "hsanson/vim-openapi" },
  {
    "tlj/api-browser.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("api-browser").setup()
    end,
    keys = {
      { "<leader>aa", "<cmd>ApiBrowser open<cr>", desc = "Select an API." },
      { "<leader>ad", "<cmd>ApiBrowser select_local_server<cr>", desc = "Select environment." },
      { "<leader>ax", "<cmd>ApiBrowser select_remote_server<cr>", desc = "Select remote environment." },
      { "<leader>ae", "<cmd>ApiBrowser endpoints<cr>", desc = "Open list of endpoints for current API." },
      { "<leader>ar", "<cmd>ApiBrowser recents<cr>", desc = "Open list of recently opened API endpoints." },
      {
        "<leader>ag",
        "<cmd>ApiBrowser endpoints_with_param<cr>",
        desc = "Open API endpoints valid for replacement text on cursor.",
      },
    },
  },
}
