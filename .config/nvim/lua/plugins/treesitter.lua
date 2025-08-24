return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "tadmccorkle/markdown.nvim",
    },
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({ ---@diagnostic disable-line: missing-fields
        ensure_installed = "all",
        sync_install = false,
        auto_install = true,
        ignore_install = {
          "bicep",
          "hoon",
          "javascript",
          "jsdoc",
          "norg",
          "org",
          "teal",
        },

        highlight = {
          enable = true,

          disable = function(lang, buf)
            local max_filesize = 5 * 1024 * 1024 -- 5 MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf)) ---@diagnostic disable-line: undefined-field
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = {},

          markdown = {
            enable = true,
          },
        },
      })

      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.plantuml = { ---@diagnostic disable-line: inject-field
        install_info = {
          url = "https://github.com/lyndsysimon/tree-sitter-plantuml",
          files = { "src/parser.c" },
          revision = "main",
        },
        filetype = "plantuml",
      }
    end,
  },
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup({
        prompt_func_return_type = {
          go = true,
          java = true,

          cpp = true,
          c = true,
        },
        prompt_func_param_type = {
          go = true,
          java = true,

          cpp = true,
          c = true,
        },
        printf_statements = {},
        print_var_statements = {},
      })
      vim.keymap.set({ "n", "x" }, "<F4>r", function()
        require("refactoring").select_refactor()
      end, { desc = "Refactor with treesitter" })

      vim.keymap.set({ "n", "x" }, "g<F4>r", function()
        require("refactoring").select_refactor()
      end, { desc = "Refactor with treesitter" })
    end,
  },
  {
    "gsuuon/tshjkl.nvim",
    config = true,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {
      labels = "asdfghjklqwertzuiopyxcvbnm",
      jump = {
        jumplist = true,
        pos = "start", ---@type "start" | "end" | "range"
        history = false,
        register = false,
        nohlsearch = false,
        autojump = false,
        inclusive = nil, ---@type boolean?
        offset = nil, ---@type number
      },
      label = {
        uppercase = true,
        exclude = "",
        current = true,
        after = true, ---@type boolean|number[]
        before = false, ---@type boolean|number[]
        style = "overlay", ---@type "eol" | "overlay" | "right_align" | "inline"
        reuse = "lowercase", ---@type "lowercase" | "all" | "none"
        distance = true,
        min_pattern_length = 0,
        rainbow = {
          enabled = true,
          -- number between 1 and 9
          shade = 5,
        },
        format = function(opts)
          return { { opts.match.label, opts.hl_group } }
        end,
      },
      highlight = {
        backdrop = true,
        matches = true,
        priority = 5000,
        groups = {
          match = "FlashMatch",
          current = "FlashCurrent",
          backdrop = "FlashBackdrop",
          label = "FlashLabel",
        },
      },
      action = nil,
      pattern = "",
      continue = false,
      config = nil, ---@type fun(opts:Flash.Config)|nil
      modes = {
        search = {
          enabled = false,
        },
        char = {
          enabled = false,
        },
        treesitter = {
          labels = "asdfghjklqwertzuiopyxcvbnm",
          jump = { pos = "range" },
          search = { incremental = false },
          label = { before = true, after = true, style = "inline" },
          highlight = {
            backdrop = false,
            matches = false,
          },
        },
        treesitter_search = {
          jump = { pos = "range" },
          search = { multi_window = true, wrap = true, incremental = false },
          remote_op = { restore = true },
          label = { before = true, after = true, style = "inline" },
        },
        remote = {
          remote_op = { restore = true, motion = true },
        },
      },
      prompt = {
        enabled = true,
        prefix = { { "⚡", "FlashPromptIcon" } },
        win_config = {
          relative = "editor",
          width = 1, -- when <=1 it's a percentage of the editor width
          height = 1,
          row = -1, -- when negative it's an offset from the bottom
          col = 0, -- when negative it's an offset from the right
          zindex = 1000,
        },
      },
      remote_op = {
        restore = false,
        motion = false,
      },
    },
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },
  {
    "danymat/neogen",
    event = "VeryLazy",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
  },
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy",
    config = function()
      require("illuminate").configure({
        -- providers: provider used to get references in the buffer, ordered by priority
        providers = {
          "lsp",
          "treesitter",
          "regex",
        },
        -- delay: delay in milliseconds
        delay = 100,
        filetype_overrides = {},
        filetypes_denylist = {
          "dirbuf",
          "dirvish",
          "fugitive",
        },
        filetypes_allowlist = {},
        modes_denylist = {},
        modes_allowlist = {},
        providers_regex_syntax_denylist = {},
        providers_regex_syntax_allowlist = {},
        under_cursor = true,
        large_file_cutoff = nil,
        large_file_overrides = nil,
        min_count_to_highlight = 1,
        should_enable = function(bufnr)
          return true
        end,
        case_insensitive_regex = false,
      })
    end,
  },
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      -- This module contains a number of default definitions
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
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
}
