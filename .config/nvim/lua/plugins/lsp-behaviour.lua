return {
  {
    "zapling/mason-lock.nvim",
    config = function()
      require("mason-lock").setup({
        lockfile_path = vim.fn.expand("$HOME/") .. "/.dotfiles/.config/nvim/mason-lock.json",
      })
    end,
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        -- java integration
        "github:nvim-java/mason-registry",
        -- c# roslyn integration
        "github:Crashdummyy/mason-registry",
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
    "saghen/blink.compat",
    version = "*",
    lazy = true,
    opts = {},
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    -- build = 'cargo build --release',
    opts = {
      keymap = {
        preset = "super-tab",
        ["<Down>"] = { "select_next", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        ghost_text = { enabled = true },
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        menu = { draw = { treesitter = { "lsp" } } },
      },
      signature = { enabled = true },
      snippets = { preset = "luasnip" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "calc" },
        providers = {
          calc = {
            name = "calc",
            module = "blink.compat.source",
            score_offset = -3,
          },
        },
      },
      cmdline = {
        keymap = {
          preset = "inherit",
          ["<C-space>"] = { "show", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<Up>"] = { "select_prev", "fallback" },
          ["<C-j>"] = { "select_next", "fallback" },
          ["<C-k>"] = { "select_prev", "fallback" },
          ["<Right>"] = { "select_next", "fallback" },
          ["<Left>"] = { "select_prev", "fallback" },
          ["<C-y>"] = { "select_and_accept" },
          ["<C-e>"] = { "cancel" },
        },
        completion = { menu = { auto_show = true } },
      },
      fuzzy = { implementation = "prefer_rust" },
    },
    opts_extend = { "sources.default" },
    dependencies = {
      "saghen/blink.compat",
      "hrsh7th/cmp-calc",
      {
        "L3MON4D3/LuaSnip",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
      -- note: diagnostics are not exclusive to lsp servers
      -- so these can be global keybindings
      vim.keymap.set("n", "<leader>xt", function()
        require("telescope.builtin").diagnostics({ bufnr = 0 })
      end, { desc = "Search diagnostics of current buffer" })
      vim.keymap.set(
        "n",
        "<leader>xT",
        require("telescope.builtin").diagnostics,
        { desc = "Search diagnostics of all buffers" }
      )
      vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump({ count = -1, float = true })
      end, { desc = "Go to previous diagnostic item" })
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump({ count = 1, float = true })
      end, { desc = "Go to next diagnostic item" })

      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition" })
          vim.keymap.set("n", "gD", function()
            vim.cmd("vsplit")
            vim.lsp.buf.definition()
          end, { buffer = event.buf, desc = "Go to definition (vsplit)" })
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = event.buf, desc = "Go to implementation" })
          vim.keymap.set("n", "gI", function()
            vim.cmd("vsplit")
            vim.lsp.buf.implementation()
          end, { buffer = event.buf, desc = "Go to implementation (vsplit)" })
          vim.keymap.set("n", "go", vim.lsp.buf.type_definition, { buffer = event.buf, desc = "Go to type definition" })
          vim.keymap.set("n", "go", function()
            vim.cmd("vsplit")
            vim.lsp.buf.type_definition()
          end, { buffer = event.buf, desc = "Go to type definition (vsplit)" })
          vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = event.buf, desc = "Show references" })
          vim.keymap.set("n", "gh", vim.lsp.buf.hover, { buffer = event.buf, desc = "Hover description" })
          vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { buffer = event.buf, desc = "Signature help" })
          vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename" })
          vim.keymap.set("n", "g<F2>", vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename" })
          vim.keymap.set({ "n", "x" }, "gf", function()
            vim.lsp.buf.format({ async = true })
          end, { buffer = event.buf, desc = "Format file or selection" })
          vim.keymap.set(
            { "n", "x" },
            "<F4><F4>",
            vim.lsp.buf.code_action,
            { buffer = event.buf, desc = "Perform lsp code action" }
          )
          vim.keymap.set(
            { "n", "x" },
            "g<F4><F4>",
            vim.lsp.buf.code_action,
            { buffer = event.buf, desc = "Perform lsp code action" }
          )
        end,
      })

      -- Enable inlay hints per default, but allow toggling
      vim.keymap.set("n", "<leader>i", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ 0 }), { 0 })
      end, { desc = "Toggle LSP inlay hints" })

      vim.lsp.inlay_hint.enable(true, { 0 })

      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = "💡",
            [vim.diagnostic.severity.INFO] = " ",
          },
          linehl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
          },
          numhl = {
            [vim.diagnostic.severity.ERROR] = "ErrorMsg",
            [vim.diagnostic.severity.WARN] = "WarningMsg",
            [vim.diagnostic.severity.HINT] = "HintMsg",
            [vim.diagnostic.severity.INFO] = "InfoMsg",
          },
        },
      })

      vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

      vim.keymap.set("n", "<leader>xd", function()
        vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })
      end, { desc = "Disable diagnostics" })

      vim.keymap.set("n", "<leader>xe", function()
        vim.diagnostic.config({ virtual_lines = true, virtual_text = false })
      end, { desc = "Enable diagnostics" })

      require("telescope").load_extension("lsp_handlers")
    end,
    dependencies = {
      "folke/neoconf.nvim",
      "williamboman/mason.nvim",
      "nvim-telescope/telescope.nvim",
      "gbrlsnchs/telescope-lsp-handlers.nvim",
    },
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")
      ls.setup({})
      -- snippets for proto are broken, which breaks lsp support for proto
      ls.filetype_set("proto", {})
    end,
  },
  {
    "mireq/luasnip-snippets",
    init = function()
      require("luasnip_snippets.common.snip_utils").setup()
    end,
    dependencies = { "L3MON4D3/LuaSnip" },
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Open diagnostics of all buffers",
      },
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Open diagnostics of current buffer",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Open diagnostics Location List",
      },
    },
  },
  {
    "liuchengxu/vista.vim",
    config = function()
      vim.cmd([[
      let g:vista_default_executive = 'nvim_lsp'
      nmap <silent> <F8> :Vista!!<CR>
      ]])
    end,
  },
}
