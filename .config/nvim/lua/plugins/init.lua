local utils = require('utils')

return {
	{
		'altercation/vim-colors-solarized',
		config = function()
			utils.load_local_vimscript("plugins/theme.vim")
		end,
		lazy = false,
		priority = 1000
	},
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
	'SirVer/ultisnips',
	{
		'RaafatTurki/hex.nvim',
		config = function()
			require('hex').setup()
		end
	},
	'honza/vim-snippets',
	{
		'w0rp/ale',
		init = function()
			utils.load_local_vimscript("plugins/ale.vim")
		end
	},
	'folke/todo-comments.nvim',
	'guns/xterm-color-table.vim',
	'vim-scripts/L9',
	'tpope/vim-surround',
	'vim-scripts/delimitMate.vim',
	'justinmk/vim-gtfo',
	'luochen1990/rainbow',
	'powerman/vim-plugin-AnsiEsc',
	'vim-scripts/DoxygenToolkit.vim',
	{
		'vim-airline/vim-airline',
		dependencies = {
			'vim-airline/vim-airline-themes'
		},
		init = function()
			vim.g.airline_theme = 'atomic'
			vim.g.airline_powerline_fonts = 1
		end
	},
	'vim-airline/vim-airline-themes',
	'preservim/vim-indent-guides',
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
	{ 'junegunn/fzf', build = './install --all' },
	'godlygeek/tabular',
	'dhruvasagar/vim-table-mode',
	'airblade/vim-gitgutter',
	'tpope/vim-fugitive',
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate'
	},
	'lervag/vimtex',
	{
		'peder2tm/sved',
		init = function()
			utils.load_local_vimscript("plugins/tex.vim")
		end
	},
	'udalov/kotlin-vim',
	{
		'fatih/vim-go',
		build = ':GoUpdateBinaries'
	},
	'dylon/vim-antlr',
	'jamessan/vim-gnupg',
	'elzr/vim-json',
	'vim-scripts/Tabmerge',
	'mkitt/tabline.vim',
	'jeetsukumaran/vim-buffergator',
	'vim-scripts/groovy.vim',
	'leafgarland/typescript-vim',
	{
		'Shougo/vimproc.vim',
		build = 'make'
	},
	'aklt/plantuml-syntax',
	{
		'heavenshell/vim-pydocstring',
		build = 'make clean && make install'
	},
	'jxnblk/vim-mdx-js',
	{
		'previm/previm',
		init = function()
			utils.load_local_vimscript("plugins/previm.vim")
		end
	},
	{
		'editorconfig/editorconfig-vim',
		init = function()
			vim.g.EditorConfig_exclude_patterns = { 'fugitive://.*' }
		end
	},
}
