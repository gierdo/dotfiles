let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'


lua << EOF
local actions = require('telescope.actions')
local action_state = require("telescope.actions.state")

local custom_actions = {}

require('telescope').load_extension('coc')
require('telescope').load_extension('gh')
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
local coc_builtin = require('telescope').extensions.coc

builtin.coc = coc_builtin.coc

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

require('telescope').setup{
defaults = {
  -- Default configuration for telescope goes here:
  -- config_key = value,
  mappings = {
    i = {
      ["<C-t>"] = actions.file_tab,
      ["<C-v>"] = actions.file_vsplit,
      ["<C-s>"] = actions.file_split,
      ["<esc>"] = actions.close,
      ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
      ["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
      ["<cr>"] = custom_actions.fzf_multi_select
      },
    n = {
      ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
      ["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
      ["<cr>"] = custom_actions.fzf_multi_select
      }
    }
  },
pickers = {
  -- Default configuration for builtin pickers goes here:
  -- picker_name = {
  --   picker_config_key = value,
  --   ...
  -- }
  -- Now the picker_config_key will be applied every time you call this
  -- builtin picker
  },
extensions = {
  -- Your extension configuration goes here:
  -- extension_name = {
  --   extension_config_key = value,
  -- }
  -- please take a look at the readme of the extension you want to configure
  }
}
EOF

" fuzzy-find in current buffer
nnoremap <A-l> <cmd>Telescope current_buffer_fuzzy_find<cr>
" fuzzy-find in all files, slow and expensive
nnoremap <C-A-l> <cmd>Telescope grep_string search=''<cr>

" Find in all files
nnoremap <A-p> <cmd>Telescope live_grep<cr>
" Fuzzy-find paths
nnoremap <C-p> <cmd>Telescope find_files<cr>

nnoremap <C-A-b> <cmd>Telescope buffers<cr>
nnoremap <C-A-p> <cmd>Telescope tags<cr>
