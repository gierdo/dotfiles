return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "saghen/blink.cmp",
    },

    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        command = "setlocal conceallevel=2",
      })

      require("obsidian").setup({
        legacy_commands = false,
        footer = { enabled = false },
        workspaces = {
          {
            name = "notes",
            path = "~/Sync/notes",
          },
          {
            name = "workspace_notes",
            path = "~/workspace/workspace_notes",
          },
          {
            name = "no-vault",
            path = function()
              -- If we are in diff mode, return the current working directory instead of the tmp directory to the diff buffer
              if vim.wo.diff then
                return vim.fn.getcwd()
              end
              return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
            end,
            overrides = { ---@diagnostic disable-line: missing-fields
              notes_subdir = vim.NIL, ---@diagnostic disable-line: assign-type-mismatch
              new_notes_location = "current_dir",
              templates = { ---@diagnostic disable-line: missing-fields
                folder = vim.NIL, ---@diagnostic disable-line: assign-type-mismatch
              },
              frontmatter = { enabled = false },
            },
          },
        },

        completion = { ---@diagnostic disable-line: missing-fields
          nvim_cmp = false,
          blink = true,
          min_chars = 2,
        },

        -- Either 'wiki' or 'markdown'.
        preferred_link_style = "markdown",

        frontmatter = { enabled = false },

        -- Optional, for templates (see below).
        templates = { ---@diagnostic disable-line: missing-fields
          folder = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          -- A map for custom variables, the key should be the variable and the value a function
          substitutions = {},
        },

        picker = { ---@diagnostic disable-line: missing-fields
          -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
          name = "telescope.nvim",
          -- Optional, configure key mappings for the picker. These are the defaults.
          -- Not all pickers support all mappings.
          note_mappings = { ---@diagnostic disable-line: missing-fields
            -- Create a new note from your query.
            new = "<C-x>",
            -- Insert a link to the selected note.
            insert_link = "<C-l>",
          },
          tag_mappings = { ---@diagnostic disable-line: missing-fields
            -- Add tag(s) to current note.
            tag_note = "<C-x>",
            -- Insert a tag at the current location.
            insert_tag = "<C-l>",
          },
        },

        search = { max_lines = 1000, sort_by = "modified", sort_reversed = true },

        -- Optional, determines how certain commands open notes. The valid options are:
        -- 1. "current" (the default) - to always open in the current window
        -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
        -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
        open_notes_in = "current",

        -- Optional, define your own callbacks to further customize behavior.
        callbacks = { ---@diagnostic disable-line: missing-fields
          -- Runs at the end of `require("obsidian").setup()`.
          ---@param client obsidian.Client
          post_setup = function(client) end,

          -- Runs anytime you enter the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          enter_note = function(client, note) end,

          -- Runs anytime you leave the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          leave_note = function(client, note) end,

          -- Runs right before writing the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          pre_write_note = function(client, note) end,

          -- Runs anytime the workspace is set/changed.
          ---@param client obsidian.Client
          ---@param workspace obsidian.Workspace
          post_set_workspace = function(client, workspace) end,
        },
        ui = {
          enable = false, -- set to false to disable all additional syntax features
        },
      })
    end,
  },
  {
    "Zeioth/markmap.nvim",
    build = "yarn global add markmap-cli",
    cmd = { "MarkmapOpen", "MarkmapSave", "MarkmapWatch", "MarkmapWatchStop" },
    opts = {
      hide_toolbar = false, -- (default)
    },
    config = function(_, opts)
      require("markmap").setup(opts)
    end,
    keys = {
      { "<leader>mm", "<cmd>MarkmapOpen<cr>", desc = "Open Markmap" },
    },
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
    keys = {
      { "<leader>mv", "<cmd>MarkdownPreview<cr>", desc = "Open markdown preview" },
    },
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
    "Kicamon/markdown-table-mode.nvim",
    config = function()
      require("markdown-table-mode").setup()
    end,
    keys = {
      { "<leader>mt", "<cmd>Mtm<cr>", desc = "Toggle markdown table mode" },
    },
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
    "aklt/plantuml-syntax",
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        -- file and directory options
        dir_path = "assets", ---@type string | fun(): string
        extension = "png", ---@type string | fun(): string
        file_name = "%Y-%m-%d-%H-%M-%S", ---@type string | fun(): string
        use_absolute_path = false, ---@type boolean | fun(): boolean
        relative_to_current_file = false, ---@type boolean | fun(): boolean

        -- logging options
        verbose = true, ---@type boolean | fun(): boolean

        -- template options
        template = "$FILE_PATH", ---@type string | fun(context: table): string
        url_encode_path = false, ---@type boolean | fun(): boolean
        relative_template_path = true, ---@type boolean | fun(): boolean
        use_cursor_in_template = true, ---@type boolean | fun(): boolean
        insert_mode_after_paste = true, ---@type boolean | fun(): boolean
        insert_template_after_cursor = true, ---@type boolean | fun(): boolean

        -- prompt options
        prompt_for_file_name = true, ---@type boolean | fun(): boolean
        show_dir_path_in_prompt = false, ---@type boolean | fun(): boolean

        -- base64 options
        max_base64_size = 10, ---@type number | fun(): number
        embed_image_as_base64 = false, ---@type boolean | fun(): boolean

        -- image options
        process_cmd = "", ---@type string | fun(): string
        copy_images = true, ---@type boolean | fun(): boolean
        download_images = true, ---@type boolean | fun(): boolean

        -- drag and drop options
        drag_and_drop = {
          enabled = true, ---@type boolean | fun(): boolean
          insert_mode = true, ---@type boolean | fun(): boolean
        },
      },

      -- filetype specific options
      filetypes = {
        markdown = {
          url_encode_path = true, ---@type boolean | fun(): boolean
          template = "![$CURSOR]($FILE_PATH)", ---@type string | fun(context: table): string
          download_images = true, ---@type boolean | fun(): boolean
        },

        vimwiki = {
          url_encode_path = true, ---@type boolean | fun(): boolean
          template = "![$CURSOR]($FILE_PATH)", ---@type string | fun(context: table): string
          download_images = true, ---@type boolean | fun(): boolean
        },

        html = {
          template = '<img src="$FILE_PATH" alt="$CURSOR">', ---@type string | fun(context: table): string
        },

        tex = {
          relative_template_path = false, ---@type boolean | fun(): boolean
          template = [[
\begin{figure}[h]
  \centering
  \includegraphics[width=0.8\textwidth]{$FILE_PATH}
  \caption{$CURSOR}
  \label{fig:$LABEL}
\end{figure}
    ]], ---@type string | fun(context: table): string
        },

        typst = {
          template = [[
#figure(
  image("$FILE_PATH", width: 80%),
  caption: [$CURSOR],
) <fig-$LABEL>
    ]], ---@type string | fun(context: table): string
        },

        rst = {
          template = [[
.. image:: $FILE_PATH
   :alt: $CURSOR
   :width: 80%
    ]], ---@type string | fun(context: table): string
        },

        asciidoc = {
          template = 'image::$FILE_PATH[width=80%, alt="$CURSOR"]', ---@type string | fun(context: table): string
        },

        org = {
          template = [=[
#+BEGIN_FIGURE
[[file:$FILE_PATH]]
#+CAPTION: $CURSOR
#+NAME: fig:$LABEL
#+END_FIGURE
    ]=], ---@type string | fun(context: table): string
        },
      },

      -- file, directory, and custom triggered options
      files = {}, ---@type table | fun(): table
      dirs = {}, ---@type table | fun(): table
      custom = {}, ---@type table | fun(): table
    },
    keys = {
      { "<leader>mp", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
}
