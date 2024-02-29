local utils = require('utils')

return {
	{
		'glacambre/firenvim',
		lazy = not vim.g.started_by_firenvim,
		build = function()
			vim.fn["firenvim#install"](0)
		end,
		config = function()
			vim.g.firenvim_config = {
				globalSettings = { alt = "all" },
				localSettings = {
					[".*"] = {
						cmdline  = "neovim",
						content  = "text",
						priority = 0,
						selector = 'textarea:not([readonly], [aria-readonly], [aria-autocomplete]), div[role="textbox"]',
						takeover = "always"
					},
					["https?://teams\\.microsoft\\.com/.*"] = { takeover = 'never', priority = 1 },
					["https?://app\\.slack\\.com/.*"] = { takeover = 'never', priority = 1 },
					["https?://app\\.mural\\.co/.*"] = { takeover = 'never', priority = 1 },
				}
			}
		end
	},
}
