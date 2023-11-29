local utils = require('utils')

vim.g.NERDTreeMapOpenInTab = "<C-t>"
vim.g.NERDTreeMapOpenVSplit = "<C-v>"
vim.g.NERDTreeMapOpenSplit = "<C-s>"

return {
	{
		'scrooloose/nerdtree',
		priority = 1,
		lazy = false,
		dependencies = {
			'jistr/vim-nerdtree-tabs',
			'Xuyuanp/nerdtree-git-plugin',
			'nvim-tree/nvim-web-devicons',
			'ryanoasis/vim-devicons',
		},
		config = function()
			utils.load_local_vimscript("plugins/nerdtree.vim")
		end
	},
	'jistr/vim-nerdtree-tabs',
	'Xuyuanp/nerdtree-git-plugin',
	'ryanoasis/vim-devicons',
	'nvim-tree/nvim-web-devicons',
}
