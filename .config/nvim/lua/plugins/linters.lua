local sonarlint_flietypes = { "java", "python" }

return {
  {
    "https://gitlab.com/schrieveslaach/sonarlint.nvim",
    ft = sonarlint_flietypes,
    config = function()
      require("sonarlint").setup({
        server = {
          cmd = vim
            .iter({
              "java",
              "-jar",
              vim.fn.expand("$MASON/packages/sonarlint-language-server/extension/server/sonarlint-ls.jar"),
              "-stdio",
              "-analyzers",
              vim.fn.expand("$MASON/share/sonarlint-analyzers/*.jar", true, 1),
            })
            :flatten()
            :totable(),
        },
        filetypes = sonarlint_flietypes,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    config = function()
      local conform = require("conform")
      conform.setup({
        default_format_opts = {
          lsp_format = "fallback",
        },
        formatters_by_ft = {
          lua = {
            "stylua",
          },
          python = {
            "black",
            "isort",
          },
          rust = {
            "rustfmt",
          },
          go = {
            "goimports",
            "gofmt",
          },
          markdown = {
            "markdownlint",
          },
          javascript = {
            "prettierd",
            "prettier",
            stop_after_first = true,
          },
          kotlin = {
            "ktlint",
          },
          proto = {
            "clang-format",
          },
          sh = {
            "shfmt",
          },
          yaml = {
            "yamlfmt",
          },
          xml = {
            "xmlformat",
          },
          ["*"] = {
            "trim_whitespace",
          },
        },
        formatters = {
          shfmt = {
            command = "shfmt",
            args = {
              "-i",
              "2",
            },
          },
        },
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_format = "fallback" }
        end,
      })
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })
      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end,
  },
  {
    "zapling/mason-conform.nvim",
    config = function()
      require("mason-conform").setup()
    end,
    dependencies = {
      "williamboman/mason.nvim",
      "stevearc/conform.nvim",
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = {
          "eslint_d",
          "trivy",
        },
        typescript = {
          "trivy",
        },
        javascriptreact = {
          "trivy",
        },
        typescriptreact = {
          "trivy",
        },
        cpp = {
          "clangtidy",
          "cppcheck",
          "cpplint",
          "flawfinder",
          "trivy",
        },
        email = {
          "languagetool",
          "write_good",
        },
        markdown = {
          "markdownlint",
        },
        c = {
          "clangtidy",
          "cppcheck",
          "cpplint",
          "flawfinder",
          "trivy",
        },
        git = {
          "commitlint",
          "gitlint",
        },
        python = {
          "mypy",
          "ruff",
          "pylint",
          "trivy",
        },
        sh = {
          "shellcheck",
          "trivy",
        },
        cmake = {
          "cmakelint",
        },
        json = {
          "jsonlint",
        },
        systemd = {
          "systemd-analyze",
        },
        kotlin = {
          "ktlint",
          "trivy",
        },
        java = {
          "trivy",
        },
        cs = {
          "trivy",
        },
        docker = {
          "trivy",
        },
        yaml = {
          "trivy",
        },
        xml = {
          "trivy",
        },
        haskell = {
          "hlint",
        },
      }

      local run_linters = function()
        lint.try_lint()
        -- Run these linters on all filetypes
        -- lint.try_lint("trivy")
      end

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          run_linters()
        end,
      })

      vim.keymap.set("n", "<leader>l", function()
        run_linters()
      end, { desc = "Trigger linting for current file" })
    end,
  },
  {
    "rshkarin/mason-nvim-lint",
    config = function()
      require("mason-nvim-lint").setup({
        automatic_installation = true,
        quiet_mode = true,
      })
    end,
    dependencies = {
      "mfussenegger/nvim-lint",
      "williamboman/mason.nvim",
    },
  },
}
