local utils = require('utils')

return {
	{
		'glacambre/firenvim',
		lazy = not vim.g.started_by_firenvim,
		build = ":call firenvim#install(0)",
		config = function()
			vim.g.firenvim_config = {
				globalSettings = { alt = "all" },
				localSettings = {
					[".*"] = {
						takeover = "never"
					},
				}
			}
		end
	},
}
