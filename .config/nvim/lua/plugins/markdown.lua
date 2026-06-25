return {
  {
    "yousefhadder/markdown-plus.nvim",
    ft = "markdown",
    opts = {
      enabled = true,
      features = {
        list_management = true,
        text_formatting = true,
        thematic_break = true,
        headers_toc = true,
        links = true,
        images = true,
        quotes = true,
        callouts = true,
        code_block = true,
        html_block_awareness = true,
        table = true,
        footnotes = true,
      },
      footnotes = {
        section_header = "Footnotes",
        confirm_delete = true,
      },
      keymaps = {
        enabled = true,
      },
      toc = {
        initial_depth = 2,
      },
      callouts = {
        default_type = "NOTE",
        custom_types = {},
      },
      table = {
        auto_format = true,
        default_alignment = "left",
        confirm_destructive = true,
        keymaps = {
          enabled = true,
          prefix = "<localleader>t",
          insert_mode_navigation = true,
        },
      },
      filetypes = { "markdown" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    config = function()
      os.execute("systemctl --user start plantuml")
      vim.cmd([[
      let g:mkdp_browser = "brave"
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
