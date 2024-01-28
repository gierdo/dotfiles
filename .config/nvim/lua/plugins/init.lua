local utils = require('utils')

return {
	{ 'nvim-lua/plenary.nvim', lazy = true }, -- lua base library
	{
		'scrooloose/nerdcommenter',
		config = function()
			vim.g.NERDDefaultAlign = 'left'
			vim.g.NERDCompactSexyComs = 0
			vim.g.NERDSpaceDelims = 1
			vim.cmd [[
			let g:NERDCustomDelimiters = {
				\ 'c': { 'left': '/*','right': '*/' },
				\ 'debsources': { 'left': '#'},
				\ 'cmake': { 'left': '#'}
				\}
			]]
		end
	},
	{
		"cappyzawa/trim.nvim",
		opts = {}
	},
	{
		'RaafatTurki/hex.nvim',
		config = function()
			require('hex').setup()
		end
	},
	'SirVer/ultisnips',
	'honza/vim-snippets',
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {}
	},
	'tpope/vim-surround',
	{
		'windwp/nvim-autopairs',
		config = function()
			local npairs = require("nvim-autopairs")

			npairs.setup({
				map_cr = false,
				check_ts = true,
			})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		}
	},
	'justinmk/vim-gtfo',
	'powerman/vim-plugin-AnsiEsc',
	{
		"JMarkin/gentags.lua",
		cond = vim.fn.executable("ctags") == 1,
		config = function()
			require("gentags").setup({})
		end,
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		'liuchengxu/vista.vim',
		config = function()
			vim.cmd("nmap <silent> <F8> :Vista!!<CR>")
		end
	},
	'dhruvasagar/vim-table-mode',
	'airblade/vim-gitgutter',
	'tpope/vim-fugitive',
	{
		'kevinhwang91/nvim-bqf',
		event = 'VeryLazy',
		dependencies = {
			'nvim-treesitter/nvim-treesitter',
			'junegunn/fzf'
		}
	},
	{
		'lervag/vimtex',
		init = function()
			vim.g.tex_flavor = 'latex'
		end
	},
	{
		'fatih/vim-go',
		build = ':GoUpdateBinaries'
	},
	'jamessan/vim-gnupg',
	'aklt/plantuml-syntax',
	{
		'tyru/open-browser.vim',
		config = function()
			vim.cmd [[
			let g:openbrowser_browser_commands = [
				\ {"name": "firefox",
				\  "args": ["{browser}", "{uri}"]},
				\ {"name": "xdg-open",
				\  "args": ["{browser}", "{uri}"]},
				\ {"name": "x-www-browser",
				\  "args": ["{browser}", "{uri}"]},
				\ {"name": "w3m",
				\  "args": ["{browser}", "{uri}"]},
				\ ]
			]]
		end
	},
	{
		'weirongxu/plantuml-previewer.vim',
		dependencies = {
			'tyru/open-browser.vim',
		},
		config = function()
			vim.g.plantuml_previewer_plantuml_jar_path = vim.env.HOME .. ".local/share/plantuml/plantuml.jar"
		end
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
			vim.g.mkdp_browser = "firefox"
			vim.g.mkdp_auto_close = 0
		end,
		ft = { "markdown" },
	},
	'tpope/vim-sleuth',
}
