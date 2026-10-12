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
    "mrjones2014/smart-splits.nvim",

    dependencies = {
      { "smart-splits-nvim/backend-tmux", main = "smart-splits-backend-tmux" },
    },
    config = function()
      require("smart-splits").setup({
        ignored_buftypes = {
          "nofile",
          "quickfix",
          "prompt",
        },
        resize = {
          amount = 3,
          ignored_events = {
            "BufEnter",
            "WinEnter",
          },
        },
        move = {
          at_edge = "wrap",
          same_row = false,
        },
        mux = {
          backend = "smart-splits-backend-tmux",
        },
        swap = {
          move_cursor = false,
        },
      })
      -- resizing splits, these accept a count, so `10<A-h>` resizes by 10 * config.resize.amount
      vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
      vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
      vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
      vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)
      -- moving between splits
      vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
      vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
      vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
      vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
      -- swapping buffers between windows
      vim.keymap.set("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
      vim.keymap.set("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
      vim.keymap.set("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
      vim.keymap.set("n", "<leader><leader>l", require("smart-splits").swap_buf_right)
    end,
  },
}
