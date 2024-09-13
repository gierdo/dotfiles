local utils = require("utils")
return {
	{
		"junegunn/fzf",
		lazy = true,
		build = "./install --all",
	},
	{
		"gelguy/wilder.nvim",
		event = "VeryLazy",
		build = function()
			vim.cmd("UpdateRemotePlugins")
		end,
		config = function()
			local wilder = require("wilder")
			wilder.setup({
				modes = { ":" },
				enable_cmdline_enter = 0,
			})
			wilder.set_option("pipeline", {
				wilder.branch(
					wilder.cmdline_pipeline({
						-- sets the language to use, 'vim' and 'python' are supported
						language = "python",
						-- 0 turns off fuzzy matching
						-- 1 turns on fuzzy matching
						-- 2 partial fuzzy matching (match does not have to begin with the same first letter)
						fuzzy = 1,
					}),
					wilder.python_search_pipeline({
						-- can be set to wilder#python_fuzzy_delimiter_pattern() for stricter fuzzy matching
						pattern = wilder.python_fuzzy_pattern(),
						-- omit to get results in the order they appear in the buffer
						sorter = wilder.python_difflib_sorter(),
						-- can be set to 're2' for performance, requires pyre2 to be installed
						-- see :h wilder#python_search() for more details
						engine = "re2",
					})
				),
			})
			wilder.set_option(
				"renderer",
				wilder.popupmenu_renderer({
					-- highlighter applies highlighting to the candidates
					highlighter = wilder.basic_highlighter(),
				})
			)
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		branch = "0.1.x",
		init = function()
			vim.keymap.set("n", "<A-l>", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
			vim.keymap.set("n", "<C-A-l>", '<cmd>Telescope grep_string search=""<cr>')
			vim.keymap.set("n", "<A-p>", "<cmd>Telescope live_grep<cr>")
			vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>")
			vim.keymap.set("n", "<C-A-b>", "<cmd>Telescope buffers<cr>")
			vim.keymap.set("n", "<C-A-p>", "<cmd>Telescope tags<cr>")
		end,
		config = function()
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")

			local custom_actions = {}

			require("telescope").load_extension("gh")
			require("telescope").load_extension("fzf")
			require("telescope").load_extension("dap")

			function custom_actions.fzf_multi_select(prompt_bufnr)
				local picker = action_state.get_current_picker(prompt_bufnr)
				local num_selections = table.getn(picker:get_multi_selection())

				if num_selections > 1 then
					-- actions.file_edit throws - context of picker seems to change
					--actions.file_edit(prompt_bufnr)
					actions.send_selected_to_qflist(prompt_bufnr)
					actions.open_qflist()
				else
					actions.select_default(prompt_bufnr)
				end
			end

			require("telescope").setup({
				defaults = {
					-- Default configuration for telescope goes here:
					-- config_key = value,
					mappings = {
						i = {
							["<C-t>"] = actions.file_tab,
							["<C-v>"] = actions.file_vsplit,
							["<C-x>"] = actions.file_split,
							["<esc>"] = actions.close,
							["<tab>"] = actions.toggle_selection + actions.move_selection_next,
							["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
							["<cr>"] = custom_actions.fzf_multi_select,
						},
						n = {
							["<tab>"] = actions.toggle_selection + actions.move_selection_next,
							["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
							["<cr>"] = custom_actions.fzf_multi_select,
						},
					},
				},
				pickers = {
					-- Default configuration for builtin pickers goes here:
					-- picker_name = {
					--   picker_config_key = value,
					--   ...
					-- }
					-- Now the picker_config_key will be applied every time you call this
					-- builtin picker
					find_files = {
						hidden = true,
					},
					lsp_references = {},
				},
				extensions = {
					-- Your extension configuration goes here:
					-- extension_name = {
					--   extension_config_key = value,
					-- }
					-- please take a look at the readme of the extension you want to configure
				},
			})
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-github.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
			"nvim-telescope/telescope-dap.nvim",
		},
	},
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		lazy = true,
		build = "make",
		dependencies = { "junegunn/fzf" },
	},
	{ "nvim-telescope/telescope-github.nvim", lazy = true },
	{ "nvim-telescope/telescope-dap.nvim", lazy = true },
	{
		"nvim-pack/nvim-spectre",
		event = "VeryLazy",
		config = function()
			require("spectre").setup()
			vim.cmd.command("Replace", "Spectre")
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
}
