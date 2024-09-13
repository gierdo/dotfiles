return {
	{
		"stevearc/conform.nvim",
		config = function()
			local conform = require("conform")
			conform.setup({
				default_format_opts = {
					lsp_format = "fallback",
				},
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					rust = { "rustfmt" },
					go = { "goimports", "gofmt" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					kotlin = { "ktlint" },
					sh = { "shfmt" },
					yaml = { "yamlfmt" },
					["*"] = { "trim_whitespace" },
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
			})
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*",
				callback = function(args)
					conform.format({ bufnr = args.buf })
				end,
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
				javascript = { "eslint_d" },
				typescript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				cpp = {
					"clangtidy",
					"cppcheck",
					"cpplint",
					"flawfinder",
				},
				email = {
					"languagetool",
					"write_good",
				},
				markdown = {
					"markdownlint",
					"write_good",
				},
				c = {
					"clangtidy",
					"cppcheck",
					"cpplint",
					"flawfinder",
				},
				git = { "gitlint", "write_good" },
				python = {
					"pylint",
					"flake8",
					"mypy",
				},
				sh = { "shellcheck" },
				cmake = {
					"cmakelint",
				},
				json = { "jsonlint" },
				systemd = { "systemd-analyze" },
				kotlin = { "ktlint" },
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>l", function()
				lint.try_lint()
			end, { desc = "Trigger linting for current file" })
		end,
	},
	{
		"rshkarin/mason-nvim-lint",
		config = function()
			require("mason-nvim-lint").setup({
				quiet_mode = true,
			})
		end,
		dependencies = {
			"mfussenegger/nvim-lint",
			"williamboman/mason.nvim",
		},
	},
}
