return {
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = "dark" -- or 'light'
      require("solarized").setup({
        transparent = {
          enabled = true,
          pmenu = false,
          normal = false,
          normalfloat = false,
          neotree = true,
          nvimtree = true,
          whichkey = true,
          telescope = true,
          lazy = true,
        },
        on_highlights = function(colors, color)
          local palette = {
            base1 = "#93A1A1",

            red = "#DC322F",
            orange = "#CB4B16",
            yellow = "#B58900",
            green = "#859900",
            aqua = "#2AA198",
            blue = "#268BD2",
            purple = "#D33682",

            diff_add = "#003200",
            diff_change = "#323200",
            diff_delete = "#320000",
            diff_text = "#404000",
          }

          local highlights = {
            SpellBad = { strikethrough = false }, -- Solarized dark defaults to striking through wrong spelling

            DiffAdd = { bg = palette.diff_add },
            DiffChange = { bg = palette.diff_change },
            DiffDelete = { bg = palette.diff_delete },
            DiffText = { bg = palette.diff_text },
            diffAdded = { fg = palette.green },
            diffRemoved = { fg = palette.red },
            diffChanged = { fg = palette.blue },
            diffOldFile = { fg = palette.yellow },
            diffNewFile = { fg = palette.orange },
            diffFile = { fg = palette.aqua },
            diffLine = { fg = palette.base1 },
            diffIndexLine = { fg = palette.purple },
            ["@text.diff.add"] = { link = "DiffAdd" },
            ["@text.diff.delete"] = { link = "DiffDelete" },
          }
          return highlights
        end,
        on_colors = nil,
        palette = "solarized", -- solarized (default) | selenized
        styles = {
          types = { bold = true },
          functions = {},
          parameters = {},
          comments = {},
          strings = {},
          keywords = {},
          variables = {},
          constants = {},
        },
        plugins = {
          treesitter = true,
          lspconfig = true,
          navic = false,
          cmp = true,
          indentblankline = true,
          neotree = false,
          nvimtree = false,
          whichkey = true,
          dashboard = true,
          gitsigns = true,
          telescope = true,
          noice = true,
          hop = false,
          ministatusline = false,
          minitabline = false,
          ministarter = false,
          minicursorword = false,
          notify = false,
          rainbowdelimiters = true,
          bufferline = false,
          lazy = true,
          rendermarkdown = true,
          neogit = true,
          todocomments = true,
          ale = false,
          gitgutter = false,
          coc = false,
          leap = false,
          alpha = false,
          yanky = false,
          flash = true,
          mason = true,
        },
      })
      vim.cmd.colorscheme("solarized")
    end,
  },
  {
    "b0o/incline.nvim",
    config = function()
      local devicons = require("nvim-web-devicons")
      require("incline").setup({
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          if filename == "" then
            filename = "[No Name]"
          end
          local ft_icon, ft_color = devicons.get_icon_color(filename)

          local function get_git_diff()
            local icons = { removed = " ", changed = " ", added = " " }
            local signs = vim.b[props.buf].gitsigns_status_dict
            local labels = {}
            if signs == nil then
              return labels
            end
            for name, icon in pairs(icons) do
              if tonumber(signs[name]) and signs[name] > 0 then
                table.insert(labels, { icon .. signs[name] .. " ", group = "Diff" .. name })
              end
            end
            if #labels > 0 then
              table.insert(labels, { "┊ " })
            end
            return labels
          end

          local function get_diagnostic_label()
            local icons = { error = " ", warn = " ", info = " ", hint = " " }
            local label = {}

            for severity, icon in pairs(icons) do
              local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
              if n > 0 then
                table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
              end
            end
            if #label > 0 then
              table.insert(label, { "┊ " })
            end
            return label
          end

          return {
            { get_diagnostic_label() },
            { get_git_diff() },
            { (ft_icon or "") .. " ", guifg = ft_color, guibg = "none" },
            { filename .. " ", gui = vim.bo[props.buf].modified and "bold,italic" or "bold" },
            { "┊  " .. vim.api.nvim_win_get_number(props.win), group = "DevIconWindows" },
          }
        end,
      })
    end,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "lewis6991/gitsigns.nvim",
    },
  },
  {
    lazy = false,
    priority = 1000,
    "nvim-lualine/lualine.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          always_show_tabline = false,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {},
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "tabs" },
        },
        winbar = {},
        inactive_winbar = {},
        extensions = {
          "quickfix",
        },
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",
    opts = {},
    config = function()
      local highlight = {
        "Whitespace",
        "CursorColumn",
      }
      require("ibl").setup({
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      })
    end,
  },
  {
    "stevearc/dressing.nvim",
    config = true,
  },
  {
    "lmilojevicc/herdr-splits.nvim",
    -- For local development, swap the repo line for `dir = '/path/to/herdr-splits'`
    -- (see "Local development" below).
    cond = vim.env.HERDR_ENV == "1",
    event = "VeryLazy",
    -- Optional: auto-sync the Herdr-side scripts when lazy updates this plugin.
    -- Requires `auto_sync_herdr = true` in setup() below to take effect.
    build = ':lua require("herdr-splits").sync_herdr()',
    config = function()
      require("herdr-splits").setup({
        -- Defaults shown. All fields optional.
        default_amount = 0.03, -- Herdr resize ratio
        neovim_amount = 3, -- Neovim resize cells
        at_edge = "wrap", -- 'wrap' | 'stop' | 'split' | function
        ignored_buftypes = { "nofile", "quickfix", "prompt", "help", "terminal" },
        ignored_filetypes = {
          "NvimTree",
          -- sidebars
          "neo-tree",
          "snacks_dashboard",
          "snacks_explorer",
          "snacks_picker",
          -- DB / REPL / data sidebars
          "dadbod-ui",
          "dbout",
          -- outlines / symbols
          "aerial",
          "Outline",
          -- diagnostics / quick lists
          "Trouble",
          "quickfix",
        },
        move_cursor_same_row = false,
        herdr_bin = nil, -- auto-detected from HERDR_BIN_PATH
        floating_zindex_max = 50, -- floats with zindex < this are treated as embedded sidebars
        ignore_previewwindows = false, -- opt-in: also treat previewwindow windows (e.g. .dbout) as sidebars
        auto_sync_herdr = true, -- opt-in: sync Herdr-side scripts on update
        -- Managed keys — written to the generated herdr-splits.conf so the
        -- Herdr-side scripts agree. Pass Neovim notation (e.g. <M-Left>).
        nav_keys = { left = "<C-h>", down = "<C-j>", up = "<C-k>", right = "<C-l>" },
        resize_keys = { left = "<M-h>", down = "<M-j>", up = "<M-k>", right = "<M-l>" },
        unzoom_on_nav = true, -- auto-unzoom when navigating away from a zoomed pane
        nav_at_edge = "wrap", -- 'wrap' | 'stop' — Herdr pane-boundary wrap (distinct from at_edge)
      })
    end,
    keys = {
      {
        "<C-h>",
        function()
          require("herdr-splits").move_cursor_left()
        end,
        desc = "Navigate left",
      },
      {
        "<C-j>",
        function()
          require("herdr-splits").move_cursor_down()
        end,
        desc = "Navigate down",
      },
      {
        "<C-k>",
        function()
          require("herdr-splits").move_cursor_up()
        end,
        desc = "Navigate up",
      },
      {
        "<C-l>",
        function()
          require("herdr-splits").move_cursor_right()
        end,
        desc = "Navigate right",
      },
      {
        "<M-h>",
        function()
          require("herdr-splits").resize_left()
        end,
        desc = "Resize left",
      },
      {
        "<M-j>",
        function()
          require("herdr-splits").resize_down()
        end,
        desc = "Resize down",
      },
      {
        "<M-k>",
        function()
          require("herdr-splits").resize_up()
        end,
        desc = "Resize up",
      },
      {
        "<M-l>",
        function()
          require("herdr-splits").resize_right()
        end,
        desc = "Resize right",
      },
    },
  },
}
