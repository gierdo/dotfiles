return {
  {
    "zapling/mason-lock.nvim",
    init = function()
      require("mason-lock").setup({})
    end,
  },
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
    config = function()
      -- note: diagnostics are not exclusive to lsp servers
      -- so these can be global keybindings
      vim.keymap.set(
        "n",
        "gl",
        "<cmd>lua require('telescope.builtin').diagnostics({bufnr=0})<cr>",
        { desc = "Open diagnostics of current buffer." }
      )
      vim.keymap.set(
        "n",
        "gL",
        "<cmd>lua require('telescope.builtin').diagnostics()<cr>",
        { desc = "Open diagnostics of all buffers." }
      )
      vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Go to previous diagnostic item." })
      vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Go to next diagnostic item." })

      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          vim.keymap.set(
            "n",
            "gd",
            "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>",
            { buffer = event.buf, desc = "Go to definition." }
          )
          vim.keymap.set(
            "n",
            "gi",
            "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>",
            { buffer = event.buf, desc = "Go to implementation." }
          )
          vim.keymap.set(
            "n",
            "go",
            "<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>",
            { buffer = event.buf, desc = "Go to type definition." }
          )
          vim.keymap.set(
            "n",
            "gr",
            "<cmd>lua require('telescope.builtin').lsp_references()<cr>",
            { buffer = event.buf, desc = "Show references." }
          )
          vim.keymap.set(
            "n",
            "gD",
            "<cmd>lua vim.lsp.buf.declaration()<cr>",
            { buffer = event.buf, desc = "Go to declaration." }
          )
          vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", { buffer = event.buf })
          vim.keymap.set(
            "n",
            "gs",
            "<cmd>lua vim.lsp.buf.signature_help()<cr>",
            { buffer = event.buf, desc = "Signature help." }
          )
          vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", { buffer = event.buf, desc = "Rename." })
          vim.keymap.set("n", "g<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", { buffer = event.buf, desc = "Rename." })
          vim.keymap.set(
            { "n", "x" },
            "gf",
            "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
            { buffer = event.buf, desc = "Format file or selection." }
          )
          vim.keymap.set(
            { "n", "x" },
            "<F4>",
            "<cmd>lua vim.lsp.buf.code_action()<cr>",
            { buffer = event.buf, desc = "Perform code action." }
          )
          vim.keymap.set(
            { "n", "x" },
            "g<F4>",
            "<cmd>lua vim.lsp.buf.code_action()<cr>",
            { buffer = event.buf, desc = "Perform code action." }
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
    end,
    dependencies = {
      "folke/neoconf.nvim",
      "williamboman/mason.nvim",
      "dcampos/nvim-snippy",
      "nvim-telescope/telescope.nvim",
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
}
