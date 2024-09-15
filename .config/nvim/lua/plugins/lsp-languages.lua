return {
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      local default_setup = function(server)
        lspconfig[server].setup({
          capabilities = lsp_capabilities,
        })
      end

      require("mason-lspconfig").setup({
        ensure_installed = {
          "ast_grep",
          "bashls",
          "clangd",
          "cmake",
          "csharp_ls",
          "eslint",
          "gitlab_ci_ls",
          "gopls",
          "gradle_ls",
          "groovyls",
          "jqls",
          "jsonls",
          "kotlin_language_server",
          "lemminx",
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "texlab",
          "ts_ls",
          "yamlls",
        },
        handlers = {
          default_setup,
        },
      })

      -- comes with nvim-java
      default_setup("jdtls")

      -- Enable decompiler for csharp-lsp
      local cs_config = {
        capabilities = lsp_capabilities,
        handlers = {
          ["textDocument/definition"] = require("csharpls_extended").handler,
          ["textDocument/typeDefinition"] = require("csharpls_extended").handler,
        },
      }
      lspconfig.csharp_ls.setup(cs_config)
    end,
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "neovim/nvim-lspconfig",
      "nvim-java/nvim-java",
      "Decodetalkers/csharpls-extended-lsp.nvim",
    },
  },
  {
    "nvim-java/nvim-java",
    config = function()
      require("java").setup()
    end,
  },
}
