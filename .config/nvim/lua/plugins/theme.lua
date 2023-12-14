return {
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.o.background = 'dark' -- or 'light'
      require('solarized').setup({
        transparent = false,    -- enable transparent background
        styles = {
          comments = {},
          functions = {},
          variables = {},
          numbers = {},
          constants = {},
          parameters = {},
          keywords = {},
          types = { bold = true },
        },
        enables = {
          bufferline = true,
          cmp = true,
          diagnostic = true,
          dashboard = true,
          editor = false,
          gitsign = true,
          hop = true,
          indentblankline = true,
          lsp = true,
          lspsaga = true,
          navic = true,
          neogit = true,
          neotree = true,
          notify = true,
          semantic = true,
          syntax = true,
          telescope = true,
          tree = false,
          treesitter = true,
          whichkey = true,
          mini = true,
        },
        highlights = function(colors, colorhelper)
          return {
            -- nvim-tree configuration
            NvimTreeSymlink = { link = 'Underlined' },
            NvimTreeSymlinkIcon = { link = 'Directory' },
            NvimTreeFolderName = { fg = colors.base0 }, -- (Directory)
            NvimTreeRootFolder = { link = 'Title' },
            NvimTreeFolderIcon = { link = 'Directory' },
            NvimTreeEmptyFolderName = { fg = colors.base0 }, -- (Directory)
            NvimTreeExecFile = { link = 'Function' },
            NvimTreeOpenedFile = { fg = colors.blue, bold = true },
            NvimTreeModifiedFile = { fg = colors.change },
            NvimTreeSpecialFile = { link = 'Special' },
            NvimTreeIndentMarker = { fg = colors.base01 },
            NvimTreeLspDiagnosticsInformation = {}, -- (DiagnosticInfo)
            NvimTreeLspDiagnosticsHint = {},        -- (DiagnosticHint)
            NvimTreeGitDirty = { fg = colors.change },
            NvimTreeGitStaged = { fg = colors.add },
            NvimTreeGitMerge = { fg = colors.change },
            NvimTreeGitRenamed = { fg = colors.add },
            NvimTreeGitNew = { fg = colors.add },
            NvimTreeGitDeleted = { fg = colors.delete },
            NvimTreeNormal = { fg = colors.base0, bg = colors.base04 },
            NvimTreeNormalFloat = { link = 'NvimTreeNormal' },
            NvimTreeEndOfBuffer = { fg = colors.base04 }, -- (NonText)

            -- general editor configuration
            ColorColumn = { bg = colors.base02 },                                                         -- used for columns
            Conceal = { fg = colors.blue },                                                               -- placeholder characters
            CurSearch = { fg = colors.base2, bg = colors.base02 },                                        -- highlight under cursor
            Cursor = { fg = colors.base03, bg = colors.base0 },                                           -- character under cursor
            lCursor = { link = 'Cursor' },                                                                -- character under the cursor
            CursorIM = { link = 'Cursor' },                                                               -- like cursor, but IME mode
            CursorColumn = { link = 'ColorColumn' },                                                      -- screen-column at the cursor
            CursorLine = { bg = colors.base02, sp = colors.base1 },                                       -- screen-line at the cursor
            Directory = { fg = colors.blue },                                                             -- directory names
            DiffAdd = { fg = colors.add, reverse = true },                                                -- Added line
            DiffChange = { fg = colors.change, reverse = true },                                          -- Changed line
            DiffDelete = { fg = colors.delete, reverse = true },                                          -- Deleted line
            DiffText = { fg = colors.blue, reverse = true },                                              -- Changed Text
            EndOfBuffer = { fg = colors.base03 },                                                         -- Filler lines (~)
            TermCursor = { link = 'Cursor' },                                                             -- Cursor in a focused terminal
            TermCursorNC = { fg = colors.base03, bg = colors.base0 },                                     -- Cursor in an unfocused terminal
            ErrorMsg = { fg = colors.error, reverse = true },                                             -- Error messages on the command line
            WinSeparator = { fg = colors.base00, bg = colors.base02 },
            Folded = { fg = colors.base0, bg = colors.base02, underline = true, bold = true },            -- Line used for closed folds
            FoldColumn = { fg = colors.base0, bg = colors.base02, bold = true },                          -- 'foldcolumn'
            SignColumn = { fg = colors.base0, bg = colors.base02 },
            IncSearch = { fg = colors.orange, standout = true },                                          -- 'incsearch' highlighting, also for the text replaced
            Substitute = { link = 'IncSearch' },                                                          -- :substitute replacement text highlight
            LineNr = { fg = colors.base01, bg = colors.base02 },
            LineNrAbove = { link = 'LineNr' },                                                            -- Line number, above the cursor line
            LineNrBelow = { link = 'LineNr' },                                                            -- Line number, below the cursor
            CursorLineNr = { fg = colors.base1, bg = colors.base02, bold = true },
            CursorLineFold = { link = 'FoldColumn' },                                                     -- Like FoldColumn when 'cursorline' is set
            CursorLineSign = { link = 'SignColumn' },                                                     -- Like SignColumn when 'cursorline' is set
            MatchParen = { fg = colors.red, bg = colors.base01, bold = true },                            -- Character under the cursor or just before it
            ModeMsg = { fg = colors.blue },                                                               -- 'showmode' message (e.g., "-- INSERT --")
            MsgArea = { link = 'Normal' },                                                                -- 'Area for messages and cmdline'
            MsgSeparator = { link = 'Normal' },                                                           -- Separator for scrolled messages msgsep.
            MoreMsg = { fg = colors.blue },                                                               -- more-prompt
            NonText = { fg = colors.base1, bold = true },                                                 -- '@' at the end of the window
            Normal = { fg = colors.base0, bg = colors.base03 },
            NormalFloat = { fg = colors.base0, bg = colors.base02 },                                      -- Normal text in floating windows
            FloatBorder = { link = 'WinSeparator', bold = true },                                         -- Border of floating windows.
            FloatTitle = { fg = colors.orange },                                                          -- Title of float windows.
            NormalNC = { link = 'Normal' },                                                               -- Normal text in non-current windows.
            Pmenu = { fg = colors.base0, bg = colors.base02 },
            PmenuSel = { fg = colors.base2, bg = colors.base01 },                                         -- Popup menu: Selected item
            PmenuKind = { link = 'Pmenu' },                                                               -- Popup menu: Normal item kind
            PmenuKindSel = { link = 'PmenuSel' },                                                         -- Popup menu: Selected item kind
            PmenuExtra = { link = 'Pmenu' },                                                              -- Popup menu: Normal item extra text
            PmenuExtraSel = { link = 'PmenuSel' },                                                        -- Popup menu: Selected item extra text
            PmenuSbar = { fg = colors.base0, bg = colors.base2 },                                         -- Popup menu: Scrollbar
            PmenuThumb = { fg = colors.base03, bg = colors.base0 },                                       -- Popup menu: Thumb of the scrollbar
            Question = { fg = colors.cyan, bold = true },                                                 -- hit-enter prompt and yes/no questions.
            QuickFixLine = { fg = colors.base0, bg = colors.base03 },                                     -- Current quickfix item in the quickfix window
            Search = { fg = colors.yellow, reverse = true },                                              -- Last search pattern highlighting
            SpecialKey = { fg = colors.red, reverse = true },                                             -- Unprintable characters: Text displayed differently from what it really is.
            SpellBad = { sp = colors.red, undercurl = true },                                             -- Word that is not recognized by the spellchecker.
            SpellCap = { sp = colors.violet, undercurl = true },                                          -- Word that should start with a capital
            SpellLocal = { sp = colors.yellow, undercurl = true },                                        -- Word that is recognized by the spellchecker as one that is used in another region
            SpellRare = { sp = colors.cyan, undercurl = true },                                           -- Word that is recognized by the spellchecker as one that is hardly ever used.
            StatusLine = { fg = colors.base02, bg = colors.base1 },                                       -- Status line of current window.
            StatusLineNC = { fg = colors.base02, bg = colors.base00 },                                    -- Status lines of not-current windows.
            TabLine = { fg = colors.base0, bg = colors.base02, sp = colors.base0, underline = true },     -- Tab pages line, not active tab page label.
            TabLineFill = { fg = colors.base0, bg = colors.base02, sp = colors.base0, underline = true }, -- Tab pages line, where there are no labels.
            TabLineSel = { fg = colors.base2, bg = colors.base01, sp = colors.base0, underline = true },  -- Tab pages line, active tab page label.
            Title = { fg = colors.orange, bold = true },                                                  -- Titles for output from ":set all", ":autocmd" etcolors.
            Visual = { bg = colors.base02, standout = true },                                             -- Visual mode selection.
            VisualNOS = { link = 'Visual' },                                                              -- Visual mode selection when vim is "Not Owning the Selection".
            WarningMsg = { fg = colors.warning, bold = true },                                            -- Warning messages.
            Whitespace = { fg = colors.base01 },                                                          -- "nbsp", "space", "tab", "multispace", "lead" and "trail" in 'listchars'.
            WildMenu = { fg = colors.base2, bg = colors.base02 },                                         -- Current match in 'wildmenu' completion.
            WinBar = { link = 'Pmenu' },                                                                  -- Window bar of current window.
            WinBarNC = { link = 'WinBar' },                                                               -- Window bar of not-current windows.
          }
        end,
        colors = {},
        theme = 'default', -- or 'neosolarized' or 'neo' for short
      })
      vim.cmd.colorscheme('solarized')
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' }
    },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_divide_middle = true,
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { 'filename' },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' }
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        winbar = {},
        inactive_winbar = {},
        extensions = {
          'quickfix',
          'nvim-tree'
        }
      }
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
      local highlight = {
        "Whitespace",
        "CursorColumn",
      }
      require("ibl").setup {
        indent = { highlight = highlight, char = "" },
        whitespace = {
          highlight = highlight,
          remove_blankline_trail = false,
        },
        scope = { enabled = false },
      }
    end
  },
  'mkitt/tabline.vim',
  'jeetsukumaran/vim-buffergator',

}
