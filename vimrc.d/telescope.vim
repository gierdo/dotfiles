let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'

lua << EOF
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-t>"] = require('telescope.actions').file_tab,
        ["<C-v>"] = require('telescope.actions').file_vsplit,
        ["<C-s>"] = require('telescope.actions').file_split
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

nnoremap <C-A-l> <cmd>Telescope current_buffer_fuzzy_find<cr>
nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <A-p> <cmd>Telescope live_grep<cr>
nnoremap <C-A-b> <cmd>Telescope buffers<cr>
nnoremap <C-A-p> <cmd>Telescope tags<cr>
