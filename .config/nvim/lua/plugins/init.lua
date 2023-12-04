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
	'vim-scripts/delimitMate.vim',
	'justinmk/vim-gtfo',
	'powerman/vim-plugin-AnsiEsc',
	'soramugi/auto-ctags.vim',
	{
		'liuchengxu/vista.vim',
		config = function()
			vim.cmd("nmap <silent> <F8> :Vista!!<CR>")
		end
	},
	{
		'vim-scripts/yaifa.vim',
		config = function()
			vim.g.yaifa_max_lines = 4096
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
	'dylon/vim-antlr',
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
		'editorconfig/editorconfig-vim',
		init = function()
			vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*' }
		end
	},
	{
		'https://codeberg.org/esensar/nvim-dev-container',
		config = function()
			require("devcontainer").setup {}
		end,
		dependencies = 'nvim-treesitter/nvim-treesitter'
	},
	-- Auto Indentation
	{
		'vim-scripts/yaifa.vim',
		config = function()
			vim.g.yaifa_max_lines = 4096
		end
	},
}
