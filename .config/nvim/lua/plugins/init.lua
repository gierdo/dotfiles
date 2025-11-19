return {
  { "nvim-lua/plenary.nvim", lazy = true }, -- lua base library
  {
    "mistricky/codesnap.nvim",
    build = "make",
    config = function()
      require("codesnap").setup({
        save_path = os.getenv("XDG_PICTURES_DIR") or (os.getenv("HOME") .. "/Pictures"),
        code_font_family = "UbuntuMono NerdFont",
        watermark_font_family = "UbuntuMono NerdFont",
        bg_x_padding = 122,
        bg_y_padding = 82,
        has_line_number = true,
        bg_theme = "sea",
        watermark = "https://gierdo.astounding.technology",
      })
    end,
  },
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
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/which-key.nvim",
    },
    config = function()
      require("todo-comments").setup()

      local wk = require("which-key")
      wk.add({
        { "<leader>p", group = "  Project" },
        {
          "<leader>pt",
          function()
            vim.cmd("TodoTrouble")
          end,
          desc = "Show todo comments in trouble",
        },
        {
          "<leader>ps",
          function()
            vim.cmd("TodoTelescope")
          end,
          desc = "Show todo comments in telescope",
        },
      })
    end,
  },
  {
    "justinmk/vim-gtfo",
  },
  {
    "powerman/vim-plugin-AnsiEsc",
  },
  {
    "kevinhwang91/nvim-bqf",
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
    "mistweaverco/kulala.nvim",
    cmd = {
      "KulalaImport",
    },
    keys = {
      { "<leader>Rs", desc = "Send request" },
      { "<leader>Ra", desc = "Send all requests" },
      { "<leader>Rb", desc = "Open scratchpad" },
    },
    ft = { "http", "rest" },
    config = function()
      local kulala = require("kulala")
      kulala.setup({ global_keymaps = true, global_keymaps_prefix = "<leader>r" })
      vim.api.nvim_create_user_command("KulalaImport", function()
        kulala.import()
      end, { desc = "Import openapi spec or bruno file in current buffer to http spec file" })
    end,
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
      { "<leader>aa", "<cmd>ApiBrowser open<cr>", desc = "Select an API" },
      { "<leader>ad", "<cmd>ApiBrowser select_local_server<cr>", desc = "Select environment" },
      { "<leader>ax", "<cmd>ApiBrowser select_remote_server<cr>", desc = "Select remote environment" },
      { "<leader>ae", "<cmd>ApiBrowser endpoints<cr>", desc = "Open list of endpoints for current API" },
      { "<leader>ar", "<cmd>ApiBrowser recents<cr>", desc = "Open list of recently opened API endpoints" },
      {
        "<leader>ag",
        "<cmd>ApiBrowser endpoints_with_param<cr>",
        desc = "Open API endpoints valid for replacement text on cursor",
      },
    },
  },
  {
    "fabridamicelli/cronex.nvim",
    opts = {},
  },
  { "ludovicchabant/vim-gutentags" },

  -- Smarter "w", "e", "b" movements
  { "chrisgrieser/nvim-spider", lazy = true },
  {
    "deponian/nvim-base64",
    version = "*",
    keys = {
      { "<Leader>b", "<Plug>(FromBase64)", mode = "x", desc = "Decode from base64" },
      { "<Leader>B", "<Plug>(ToBase64)", mode = "x", desc = "Encode to base64" },
    },
    config = function()
      require("nvim-base64").setup()
    end,
  },
}
