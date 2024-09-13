return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
		},
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- note: diagnostics are not exclusive to lsp servers
			-- so these can be global keybindings
			vim.keymap.set("n", "gl", "<cmd>lua require('telescope.builtin').diagnostics({bufnr=0})<cr>") -- Open diagnostics of current buffer
			vim.keymap.set("n", "gL", "<cmd>lua require('telescope.builtin').diagnostics()<cr>") -- Open diagnostics of all buffers
			vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
			vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<cr>")

			vim.api.nvim_create_autocmd("LspAttach", {
				desc = "LSP actions",
				callback = function(event)
					local opts = { buffer = event.buf }

					-- these will be buffer-local keybindings
					-- because they only work if you have an active language server

					vim.keymap.set("n", "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", opts)
					vim.keymap.set("n", "gi", "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>", opts)
					vim.keymap.set("n", "go", "<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>", opts)
					vim.keymap.set("n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", opts)
					vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
					vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
					vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
					vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
					vim.keymap.set({ "n", "x" }, "gf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
					vim.keymap.set({ "n", "x" }, "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
				end,
			})

			local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

			local default_setup = function(server)
				require("lspconfig")[server].setup({
					capabilities = lsp_capabilities,
				})
			end

			require("mason").setup({})
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

			local cmp = require("cmp")

			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end
			local snippy = require("snippy")

			cmp.setup({
				sources = {
					{ name = "nvim_lsp" },
					{ name = "snippy" },
					{ name = "nvim_lsp_signature_help" },
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
		end,
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"dcampos/nvim-snippy",
			"dcampos/cmp-snippy",
			"nvim-telescope/telescope.nvim",
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
