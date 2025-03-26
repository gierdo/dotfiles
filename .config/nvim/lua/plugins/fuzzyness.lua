return {
  {
    "junegunn/fzf",
    lazy = true,
    build = "./install --all",
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
          actions.send_selected_to_qflist(prompt_bufnr)
          actions.open_qflist()
        else
          actions.select_default(prompt_bufnr)
        end
      end

      telescope.setup({
        defaults = {
          -- Default configuration for telescope goes here:
          -- config_key = value,
          layout_strategy = "horizontal",
          layout_config = { height = 0.95, width = 0.95 },
          mappings = {
            i = {
              ["<C-t>"] = actions.file_tab,
              ["<C-v>"] = actions.file_vsplit,
              ["<C-x>"] = actions.file_split,
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
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("zoxide")
      telescope.load_extension("dap")

      vim.keymap.set("n", "<A-l>", builtin.current_buffer_fuzzy_find, { desc = "Find in current file" })
      vim.keymap.set("n", "-", builtin.current_buffer_fuzzy_find, { desc = "Find in current file" })
      vim.keymap.set("n", "<C-A-l>", function()
        builtin.grep_string({ search = "" })
      end, { desc = "Fuzzy-find in files" })
      vim.keymap.set("n", "<A-p>", builtin.live_grep, { desc = "Find in files" })
      vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<A-b>", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<C-A-p>", builtin.tags, { desc = "Find Code tags" })
      vim.keymap.set({ "n", "x", "i" }, "<F1>", builtin.help_tags, { desc = "Find help tags" })
      vim.keymap.set(
        "n",
        "<C-d>",
        telescope.extensions.zoxide.list,
        { desc = "Show recent directories", noremap = true, silent = true }
      )
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
      "nvim-telescope/telescope-dap.nvim",
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
