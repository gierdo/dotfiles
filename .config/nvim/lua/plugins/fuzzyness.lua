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
    config = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local custom_actions = {}
      local builtin = require("telescope.builtin")

      local telescope = require("telescope")

      function custom_actions.fzf_multi_select(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local num_selections = #picker:get_multi_selection()

        if num_selections > 1 then
          -- actions.file_edit throws - context of picker seems to change
          --actions.file_edit(prompt_bufnr)
          actions.send_selected_to_qflist(prompt_bufnr)
          actions.open_qflist()
        else
          actions.select_default(prompt_bufnr)
        end
      end

      local fb_actions = require("telescope").extensions.file_browser.actions
      telescope.setup({
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
          find_files = {
            hidden = true,
          },
          lsp_references = {},
        },
        extensions = {
          file_browser = {
            hidden = {
              file_browser = true,
              folder_browser = true,
            },
            hijack_netrw = true,
            mappings = {
              i = {
                ["<A-w>"] = fb_actions.change_cwd,
              },
              n = {
                ["<A-w>"] = fb_actions.change_cwd,
              },
            },
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("dap")
      telescope.load_extension("file_browser")
      telescope.load_extension("ui-select")
      telescope.load_extension("zoxide")

      vim.keymap.set("n", "<C-n>", telescope.extensions.file_browser.file_browser, { desc = "Show file browser" })
      vim.keymap.set(
        "n",
        "<A-n>",
        ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
        { desc = "Open current path in file browser" }
      )
      vim.keymap.set("n", "<A-l>", builtin.current_buffer_fuzzy_find, { desc = "Find in current file" })
      vim.keymap.set("n", "<C-A-l>", function()
        builtin.grep_string({ search = "" })
      end, { desc = "Fuzzy-find in files" })
      vim.keymap.set("n", "<A-p>", builtin.live_grep, { desc = "Find in files" })
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<C-A-b>", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<C-A-p>", builtin.tags, { desc = "Find Code tags" })
      vim.keymap.set({ "n", "x", "i" }, "<F1>", builtin.help_tags, { desc = "Find help tags" })
      vim.keymap.set(
        "n",
        "<C-d>",
        telescope.extensions.zoxide.list,
        { desc = "Show recent directories", noremap = true, silent = true }
      )

      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argv(0) == "" then
            builtin.find_files()
          end
        end,
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-dap.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "jvgrootveld/telescope-zoxide",
    },
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    lazy = true,
    build = "make",
    dependencies = { "junegunn/fzf" },
  },
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
