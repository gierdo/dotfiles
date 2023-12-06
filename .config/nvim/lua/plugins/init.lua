local utils = require('utils')

return {
	'nvim-lua/plenary.nvim', -- lua base library
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
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	},
	'tpope/vim-surround',
	{
		'windwp/nvim-autopairs',
		config = function()
			local npairs = require("nvim-autopairs")
			local Rule = require('nvim-autopairs.rule')

			npairs.setup({
				check_ts = true,
			})

			local ts_conds = require('nvim-autopairs.ts-conds')

			-- press % => %% only while inside a comment or string
			npairs.add_rules({
				Rule("%", "%", "lua")
						:with_pair(ts_conds.is_ts_node({ 'string', 'comment' })),
				Rule("$", "$", "lua")
						:with_pair(ts_conds.is_not_ts_node({ 'function' }))
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
	'godlygeek/tabular',
	'dhruvasagar/vim-table-mode',
	'airblade/vim-gitgutter',
	'tpope/vim-fugitive',
	'kevinhwang91/nvim-bqf',
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
		'previm/previm',
		init = function()
			-- If x-www-browser is not set, assume firefox
			local x_browser = 'x-www-browser'
			if vim.fn.executable(x_browser) == 1 then
				vim.g.previm_open_cmd = x_browser
			else
				vim.g.previm_open_cmd = 'firefox'
			end
		end
	},
	{
		'https://codeberg.org/esensar/nvim-dev-container',
		config = function()
			require("devcontainer").setup {}
		end,
		dependencies = 'nvim-treesitter/nvim-treesitter'
	},
	{
		'nmac427/guess-indent.nvim',
		config = function()
			require('guess-indent').setup {}
		end,
	},
}
