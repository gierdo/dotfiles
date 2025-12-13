local lsp_capabilities = require("blink.cmp").get_lsp_capabilities(nil, true)

local configure_lsps = function()
  vim.lsp.config("*", {
    capabilities = lsp_capabilities,
  })

  vim.lsp.config("ty", {
    capabilities = lsp_capabilities,
    settings = {
      ty = {
        disableLanguageServices = true, -- For now, only use ty for typechecking
        diagnosticMode = "workspace",
        experimental = {
          rename = false,
          autoImport = false,
        },
      },
    },
  })

  vim.lsp.config("basedpyright", {
    capabilities = lsp_capabilities,
    settings = {
      basedpyright = {
        disableOrganizeImports = true, -- handled by ruff
        analysis = {
          typeCheckingMode = "off", -- Use ty for typechecking
          -- For reference, if I want to use ty's inlay hints later
          -- inlayHints = {
          --   variableTypes = false,
          --   callArgumentNames = false,
          --   functionReturnTypes = false,
          --   genericTypes = false,
          -- },
          autoImportCompletions = true,
        },
      },
    },
  })

  -- vim.lsp.config("pyrefly", {
  --   capabilities = lsp_capabilities,
  --   settings = {
  --     python = {
  --       pyrefly = {
  --         disableLanguageServices = false,
  --         displayTypeErrors = "force-on",
  --       },
  --       analysis = {
  --         diagnosticMode = "workspace",
  --         inlayHints = {
  --           callArgumentNames = "all",
  --           variableTypes = true,
  --           functionReturnTypes = true,
  --           pytestParameters = true,
  --         },
  --       },
  --     },
  --   },
  -- })

  vim.lsp.config("clangd", {
    capabilities = lsp_capabilities,
    filetypes = {
      "c",
      "cpp",
      "objc",
      "objcpp",
      "cuda",
    },
  })

  vim.lsp.config("graphql", {
    capabilities = lsp_capabilities,
    filetypes = {
      "graphql",
      "typescript",
      "typescriptreact",
      "javascriptreact",
    },
  })

  vim.lsp.config("ruff", {
    capabilities = lsp_capabilities,
    init_options = {
      settings = {
        configurationPreference = "filesystemFirst",
      },
    },
  })

  vim.lsp.config("ts_ls", {
    capabilities = lsp_capabilities,
    settings = {
      javascript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        },
      },
      typescript = {
        inlayHints = {
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        },
      },
    },
  })

  -- Avoid race condition between css and ts ls
  local css_ls_capabilities = require("blink.cmp").get_lsp_capabilities({ definitionProvider = false })
  vim.lsp.config("cssmodules_ls", {
    capabilities = css_ls_capabilities,
  })

  vim.lsp.config("jsonls", {
    capabilities = lsp_capabilities,
    settings = {
      json = {
        schemas = require("schemastore").json.schemas({
          extra = {
            { ---@diagnostic disable-line: missing-fields
              name = "OpenAPI",
              description = "OpenAPI spec",
              filetypes = { "openapi.json" },
              url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.yaml",
            },
          },
          validate = { enable = true },
        }),
        validate = { enable = true },
        schemaDownload = { enable = false },
      },
    },
  })

  vim.lsp.config("yamlls", {
    capabilities = lsp_capabilities,
    settings = {
      yaml = {
        schemaStore = {
          enable = false,
          url = "",
        },
        schemas = require("schemastore").yaml.schemas({
          validate = { enable = true },
          extra = {
            {
              name = "Cloudformation",
              description = "Cloudformation Template",
              fileMatch = { "*.template.y*ml", "*-template.y*ml" },
              url = "https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json",
            },
            { ---@diagnostic disable-line: missing-fields
              name = "OpenAPI",
              description = "OpenAPI spec",
              filetypes = { "openapi.yaml" },
              url = "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/schemas/v3.0/schema.yaml",
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
end

return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    config = function()
      require("mason-tool-installer").setup({

        -- a list of all tools you want to ensure are installed upon
        -- start
        ensure_installed = {
          -- { "golangci-lint", version = "v1.47.0" },
          -- { "bash-language-server", auto_update = true },

          -- C# Integration
          { "roslyn" },
        },
        auto_update = false,
        run_on_start = true,
        start_delay = 3000, -- 3 second delay
        debounce_hours = 5, -- at least 5 hours between attempts to install/update
        integrations = {
          ["mason-lspconfig"] = true,
          ["mason-null-ls"] = false,
          ["mason-nvim-dap"] = true,
        },
      })
    end,
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    config = function()
      require("mason-lspconfig").setup({ ---@diagnostic disable-line: missing-fields
        ensure_installed = {
          "ast_grep",
          "basedpyright",
          "bashls",
          "clangd",
          "cmake",
          "cssls",
          "cssmodules_ls",
          "cypher_ls",
          "dockerls",
          "eslint",
          "gitlab_ci_ls",
          "gopls",
          "graphql",
          "html",
          "jinja_lsp",
          "jqls",
          "jsonls",
          "kotlin_language_server",
          "lemminx",
          "lua_ls",
          "marksman",
          -- "pyrefly",
          "ruff",
          "rust_analyzer",
          "sqls",
          "taplo",
          "texlab",
          "ts_ls",
          "ty",
          "yamlls",
        },
        automatic_enable = true,
        automatic_installation = true,
      })

      configure_lsps()
    end,
    dependencies = {
      "b0o/schemastore.nvim",
      "saghen/blink.cmp",
      "mason-org/mason.nvim",
      "seblj/roslyn.nvim",
    },
  },
  {
    "folke/lazydev.nvim", -- improve lua development experience, especially concerning nvim config
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "ray-x/go.nvim",
    config = function()
      require("go").setup()
      -- The plugin enables virtual text diagnostics, which is not what I want
      vim.diagnostic.config({
        virtual_lines = { current_line = true },
        virtual_text = false,
      })
    end,
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    opts = {},
    dependencies = {
      -- Allow setting up the registry
      "mason-org/mason.nvim",
    },
  },

  {
    "nvim-java/nvim-java",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("java").setup({
        java_debug_adapter = {
          enable = true,
        },
        java_test = {
          enable = true,
        },
        lombok = {
          enable = true,
        },
        spring_boot_tools = {
          enable = true,
        },
      })
      vim.lsp.enable("jdtls")
    end,
  },
}
