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

          -- Dependencies for nvim-java
          { "jdtls" },
          { "lombok-nightly" },
          { "java-test" },
          { "java-debug-adapter" },
          { "spring-boot-tools" },

          -- Sonarlint, configured separately, ensure installation here
          { "sonarlint-language-server" },
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
      local lsp_capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      local default_setup = function(server_name)
        lspconfig[server_name].setup({
          capabilities = lsp_capabilities,
        })
      end

      local handlers = {
        default_setup,
        ["basedpyright"] = function()
          lspconfig.basedpyright.setup({
            capabilities = lsp_capabilities,
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = "standard",
                },
              },
            },
          })
        end,
        ["clangd"] = function()
          lspconfig.clangd.setup({
            capabilities = lsp_capabilities,
            filetypes = {
              "c",
              "cpp",
              "objc",
              "objcpp",
              "cuda",
            },
          })
        end,
        ["graphql"] = function()
          lspconfig.graphql.setup({
            capabilities = lsp_capabilities,
            filetypes = {
              "graphql",
              "typescript",
              "typescriptreact",
              "javascriptreact",
            },
          })
        end,
        ["ts_ls"] = function()
          lspconfig.ts_ls.setup({
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
        end,
        ["jsonls"] = function()
          lspconfig.jsonls.setup({
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
        end,
        ["yamlls"] = function()
          lspconfig.yamlls.setup({
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
        end,
      }

      require("mason-lspconfig").setup({ ---@diagnostic disable-line: missing-fields
        ensure_installed = {
          "ast_grep",
          "bashls",
          "bzl",
          "clangd",
          "cmake",
          "cypher_ls",
          "dockerls",
          "eslint",
          "gitlab_ci_ls",
          "gopls",
          "graphql",
          "gradle_ls",
          "html",
          "jinja_lsp",
          "jqls",
          "jsonls",
          "kotlin_language_server",
          "lemminx",
          "lua_ls",
          "marksman",
          "basedpyright",
          "rust_analyzer",
          "sqls",
          "texlab",
          "ts_ls",
          "yamlls",
        },
        handlers = handlers,
        automatic_installation = true,
      })

      -- comes with nvim-java
      default_setup("jdtls")

      -- protobuf lsp built-in into buf
      default_setup("buf_ls")

      -- kulala ls for rest and http files
      default_setup("kulala_ls")
    end,
    dependencies = {
      "b0o/schemastore.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
      "nvim-java/nvim-java",
      "mason-org/mason.nvim",
      "seblj/roslyn.nvim",
    },
  },
  {
    "nvim-java/nvim-java",
    event = "VeryLazy",
    config = function()
      local java = require("java")

      local override_setup = function()
        -- Override the nvim-java setup function in order to allow following the latest dependency versions (jdtls, ...)
        local custom_config = {}
        local decomple_watch = require("java.startup.decompile-watcher")
        local setup_wrap = require("java.startup.lspconfig-setup-wrap")
        local dap_api = require("java.api.dap")
        local global_config = require("java.config")
        vim.api.nvim_exec_autocmds("User", { pattern = "JavaPreSetup" })
        local config = vim.tbl_deep_extend("force", global_config, custom_config or {})
        vim.g.nvim_java_config = config
        vim.api.nvim_exec_autocmds("User", { pattern = "JavaSetup", data = { config = config } })
        setup_wrap.setup(config)
        decomple_watch.setup()
        dap_api.setup_dap_on_lsp_attach()
        vim.api.nvim_exec_autocmds("User", { pattern = "JavaPostSetup", data = { config = config } })
      end

      java.setup = override_setup

      java.setup()
    end,
    dependencies = {
      {
        "nvim-java/nvim-java-core",
        url = "https://github.com/Kabil777/nvim-java-core.git",
        branch = "fix/mason-api-update",
      },
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
      "neovim/nvim-lspconfig",
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
    "nvim-flutter/flutter-tools.nvim",
    config = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim",
    },
  },
}
