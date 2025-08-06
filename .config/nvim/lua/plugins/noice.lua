return {
  {
    "folke/noice.nvim",
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          opts = {},
          ---@type table<string, CmdlineFormat>
          format = {
            -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
            -- view: (default is cmdline view)
            -- opts: any options passed to the view
            -- icon_hl_group: optional hl_group for the icon
            -- title: set to anything or empty string to hide
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
            calculator = { pattern = "^=", icon = "", lang = "vimnormal" },
            input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
            -- lua = false, -- to disable a format, set to `false`
          },
        },
        messages = {
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
          view_history = "messages",
          view_search = "virtualtext",
        },
        popupmenu = {
          enabled = false,
        },
        -- default options for require('noice').redirect
        -- see the section on Command Redirection
        ---@type NoiceRouteConfig
        redirect = {
          view = "popup",
          filter = { event = "msg_show" },
        },
        -- You can add any custom commands below that will be available with `:Noice command`
        ---@type table<string, NoiceCommand>
        ---
        commands = {
          history = {
            -- options for the message history that you get with `:Noice`
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {
              any = {
                { event = "notify" },
                { error = true },
                { warning = true },
                { event = "msg_show", kind = { "" } },
                { event = "lsp",      kind = "message" },
              },
            },
          },
          -- :Noice last
          last = {
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = {
              any = {
                { event = "notify" },
                { error = true },
                { warning = true },
                { event = "msg_show", kind = { "" } },
                { event = "lsp",      kind = "message" },
              },
            },
            filter_opts = { count = 1 },
          },
          -- :Noice errors
          errors = {
            -- options for the message history that you get with `:Noice`
            view = "popup",
            opts = { enter = true, format = "details" },
            filter = { error = true },
            filter_opts = { reverse = true },
          },
          all = {
            -- options for the message history that you get with `:Noice`
            view = "split",
            opts = { enter = true, format = "details" },
            filter = {},
          },
        },
        notify = {
          enabled = true,
          view = "notify",
        },
        lsp = {
          progress = {
            enabled = true,
            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
            -- See the section on formatting for more details on how to customize.
            --- @type NoiceFormat|string
            format = "lsp_progress",
            --- @type NoiceFormat|string
            format_done = "lsp_progress_done",
            throttle = 1000 / 10, -- frequency to update lsp progress message
            view = "mini",
          },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
            ["vim.lsp.util.stylize_markdown"] = false,
            ["cmp.entry.get_documentation"] = false,
          },
          hover = {
            enabled = true,
            silent = true, -- set to true to not show a message if hover is not available
            view = nil,  -- when nil, use defaults from documentation
            ---@type NoiceViewOptions
            opts = {},   -- merged with defaults from documentation
          },
          signature = {
            enabled = false,
            auto_open = {
              enabled = true,
              trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
              luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
              snipppets = true, -- Will open when jumping to placeholders in snippets (Neovim builtin snippets)
              throttle = 50,  -- Debounce lsp signature help request by 50ms
            },
            view = nil,       -- when nil, use defaults from documentation
            ---@type NoiceViewOptions
            opts = {},        -- merged with defaults from documentation
          },
          message = {
            -- Messages shown by lsp servers
            enabled = false,
            view = "notify",
            opts = {},
          },
          -- defaults for hover and signature help
          documentation = {
            view = "hover",
            ---@type NoiceViewOptions
            opts = {
              replace = true,
              render = "plain",
              format = { "{message}" },
              win_options = { concealcursor = "n", conceallevel = 3 },
            },
          },
        },
        health = {
          checker = false, -- Disable if you don't want health checks to run
        },
        ---@type NoicePresets
        presets = {
          -- you can enable a preset by setting it to true, or a table that will override the preset config
          -- you can also add custom presets that you can enable/disable with enabled=true
          bottom_search = false,         -- use a classic bottom cmdline for search
          command_palette = false,       -- position the cmdline and popupmenu together
          long_message_to_split = true,  -- long messages will be sent to a split
          inc_rename = false,            -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false,        -- add a border to hover docs and signature help
          cmdline_output_to_split = false, -- send the output of a command you executed in the cmdline to a split
        },
        throttle = 1000 / 30,            -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
        ---@type NoiceConfigViews
        views = {}, ---@see section on views
        ---@type NoiceRouteConfig[]
        routes = {
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "written",
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = "msg_show",
              kind = "",
              find = "Prompt",
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = "notify",
              kind = "info",
              find = "SonarQube",
            },
            opts = { skip = true },
          },
          {
            filter = {
              event = "msg_show",
              kind = "",
            },
            opts = { skip = true },
          },
        },         --- @see section on routes
        ---@type table<string, NoiceFilter>
        status = {}, --- @see section on statusline components
        ---@type NoiceFormatOptions
        format = {}, --- @see section on formatting
        debug = false,
        log = vim.fn.stdpath("state") .. "/noice.log",
        log_max_size = 1024 * 1024 * 2, -- 10MB
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  }
}
