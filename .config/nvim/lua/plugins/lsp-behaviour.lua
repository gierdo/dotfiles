return {
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:nvim-java/mason-registry",
        "github:mason-org/mason-registry",
      },
    },
  },
  {
    "folke/neoconf.nvim",
    config = function()
      require("neoconf").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
      -- note: diagnostics are not exclusive to lsp servers
      -- so these can be global keybindings
      vim.keymap.set("n", "gl", function()
        require("telescope.builtin").diagnostics({ bufnr = 0 })
      end, { desc = "Open diagnostics of current buffer." })
      vim.keymap.set(
        "n",
        "<leader>xt",
        require("telescope.builtin").diagnostics,
        { desc = "Open diagnostics of all buffers (Telescope)" }
      )
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic item." })
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic item." })

      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition." })
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = event.buf, desc = "Go to implementation." })
          vim.keymap.set(
            "n",
            "go",
            vim.lsp.buf.type_definition,
            { buffer = event.buf, desc = "Go to type definition." }
          )
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = event.buf, desc = "Show references." })
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "Go to declaration." })
          vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = event.buf })
          vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { buffer = event.buf, desc = "Signature help." })
          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename." })
          vim.keymap.set("n", "g<F2>", vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename." })
          vim.keymap.set({ "n", "x" }, "gf", function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = event.buf, desc = "Format file or selection." })
          vim.keymap.set(
            { "n", "x" },
            "<F4><F4>",
            vim.lsp.buf.code_action,
            { buffer = event.buf, desc = "Perform lsp code action." }
          )
          vim.keymap.set(
            { "n", "x" },
            "g<F4><F4>",
            vim.lsp.buf.code_action,
            { buffer = event.buf, desc = "Perform lsp code action." }
          )
        end,
      })

      local cmp = require("cmp")

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local snippy = require("snippy")

      cmp.setup({
        sources = {
          { name = "nvim_lsp" },
          { name = "calc" },
          { name = "path" },
          { name = "conventionalcommits" },
          { name = "nvim_lsp_signature_help" },
          { name = "snippy" },
          { name = "orgmode" },
        },
        snippet = {
          expand = function(args)
            -- vim.snippet.expand(args.body) as potential replacement
            require("snippy").expand_snippet(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              else
                cmp.select_next_item()
              end
            elseif snippy.can_expand_or_advance() then
              snippy.expand_or_advance()
            elseif has_words_before() then
              cmp.complete()
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              end
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
      })

      local signs = {
        Error = " ",
        Warn = " ",
        Hint = "💡",
        Info = " ",
      }

      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      require("telescope").load_extension("lsp_handlers")
    end,
    dependencies = {
      "folke/neoconf.nvim",
      "williamboman/mason.nvim",
      "dcampos/nvim-snippy",
      -- fuzzy handlers
      "nvim-telescope/telescope.nvim",
      "gbrlsnchs/telescope-lsp-handlers.nvim",
      -- cmp + sources
      "dcampos/cmp-snippy",
      "davidsierradz/cmp-conventionalcommits",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-calc",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
    },
  },
  {
    "honza/vim-snippets",
    event = "VeryLazy",
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
}
