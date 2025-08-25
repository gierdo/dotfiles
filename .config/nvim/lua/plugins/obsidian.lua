return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "saghen/blink.cmp",
    },

    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        command = "setlocal conceallevel=2",
      })

      require("obsidian").setup({
        legacy_commands = false,
        workspaces = {
          {
            name = "notes",
            path = "~/Sync/notes",
          },
          {
            name = "workspace_notes",
            path = "~/workspace/workspace_notes",
          },
          {
            name = "no-vault",
            path = function()
              return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
            end,
            overrides = { ---@diagnostic disable-line: missing-fields
              notes_subdir = vim.NIL, ---@diagnostic disable-line: assign-type-mismatch
              new_notes_location = "current_dir",
              templates = { ---@diagnostic disable-line: missing-fields
                folder = vim.NIL, ---@diagnostic disable-line: assign-type-mismatch
              },
              disable_frontmatter = true,
            },
          },
        },

        completion = { ---@diagnostic disable-line: missing-fields
          nvim_cmp = false,
          blink = true,
          min_chars = 2,
        },

        ---
        ---@param url string
        follow_url_func = function(url)
          vim.ui.open(url)
        end,

        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an image
        -- file it will be ignored but you can customize this behavior here.
        ---@param img string
        follow_img_func = function(img)
          vim.fn.jobstart({ "xdg-open", img }) -- linux
        end,

        -- Either 'wiki' or 'markdown'.
        preferred_link_style = "markdown",

        -- Optional, boolean or a function that takes a filename and returns a boolean.
        -- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
        disable_frontmatter = false,

        -- Optional, for templates (see below).
        templates = { ---@diagnostic disable-line: missing-fields
          folder = "templates",
          date_format = "%Y-%m-%d",
          time_format = "%H:%M",
          -- A map for custom variables, the key should be the variable and the value a function
          substitutions = {},
        },

        picker = { ---@diagnostic disable-line: missing-fields
          -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
          name = "telescope.nvim",
          -- Optional, configure key mappings for the picker. These are the defaults.
          -- Not all pickers support all mappings.
          note_mappings = { ---@diagnostic disable-line: missing-fields
            -- Create a new note from your query.
            new = "<C-x>",
            -- Insert a link to the selected note.
            insert_link = "<C-l>",
          },
          tag_mappings = { ---@diagnostic disable-line: missing-fields
            -- Add tag(s) to current note.
            tag_note = "<C-x>",
            -- Insert a tag at the current location.
            insert_tag = "<C-l>",
          },
        },

        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,

        -- Set the maximum number of lines to read from notes on disk when performing certain searches.
        search_max_lines = 1000,

        -- Optional, determines how certain commands open notes. The valid options are:
        -- 1. "current" (the default) - to always open in the current window
        -- 2. "vsplit" - to open in a vertical split if there's not already a vertical split
        -- 3. "hsplit" - to open in a horizontal split if there's not already a horizontal split
        open_notes_in = "current",

        -- Optional, define your own callbacks to further customize behavior.
        callbacks = { ---@diagnostic disable-line: missing-fields
          -- Runs at the end of `require("obsidian").setup()`.
          ---@param client obsidian.Client
          post_setup = function(client) end,

          -- Runs anytime you enter the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          enter_note = function(client, note) end,

          -- Runs anytime you leave the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          leave_note = function(client, note) end,

          -- Runs right before writing the buffer for a note.
          ---@param client obsidian.Client
          ---@param note obsidian.Note
          pre_write_note = function(client, note) end,

          -- Runs anytime the workspace is set/changed.
          ---@param client obsidian.Client
          ---@param workspace obsidian.Workspace
          post_set_workspace = function(client, workspace) end,
        },
        ui = {
          enable = false, -- set to false to disable all additional syntax features
        },
      })
    end,
  },
}
