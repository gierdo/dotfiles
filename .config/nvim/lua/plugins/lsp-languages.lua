return {
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
			local default_setup = function(server)
				require("lspconfig")[server].setup({
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
					"jdtls",
					"jqls",
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
		end,
		dependencies = {
			"williamboman/mason.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"neovim/nvim-lspconfig",
		},
	},
	{
		-- Enable decompiler for csharp-lsp
		"Decodetalkers/csharpls-extended-lsp.nvim",
		config = function()
			local config = {
				handlers = {
					["textDocument/definition"] = require("csharpls_extended").handler,
					["textDocument/typeDefinition"] = require("csharpls_extended").handler,
				},
			}
			require("lspconfig").csharp_ls.setup(config)
		end,
		dependencies = {
			"neovim/nvim-lspconfig",
		},
	},
}
