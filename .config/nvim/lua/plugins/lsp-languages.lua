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

      -- Set and extend yaml/json schemas

      lspconfig.jsonls.setup({
        capabilities = lsp_capabilities,
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
            schemaDownload = { enable = false },
          },
        },
      })

      lspconfig.yamlls.setup({
        capabilities = lsp_capabilities,
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = "",
            },
            schemas = require("schemastore").yaml.schemas({
              extra = {
                {
                  name = "Cloudformation",
                  description = "Cloudformation Template",
                  fileMatch = { "*.template.y*ml", "*-template.y*ml" },
                  url = "https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json",
                },
              },
            }),
            customTags = {
              -- Cloudformation tags
              "!And scalar",
              "!If scalar",
              "!Not",
              "!Equals scalar",
              "!Or scalar",
              "!FindInMap scalar",
              "!Base64",
              "!Cidr",
              "!Ref",
              "!Sub",
              "!GetAtt sequence",
              "!GetAZs",
              "!ImportValue sequence",
              "!Select sequence",
              "!Split sequence",
              "!Join sequence",
            },
          },
        },
      })
    end,
    dependencies = {
      "b0o/schemastore.nvim",
      "Decodetalkers/csharpls-extended-lsp.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "neovim/nvim-lspconfig",
      "nvim-java/nvim-java",
      "williamboman/mason.nvim",
    },
  },
  {
    "nvim-java/nvim-java",
    config = function()
      require("java").setup()
    end,
  },
}
