return {
  "harrisoncramer/gitlab.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
    "stevearc/dressing.nvim",
    "nvim-tree/nvim-web-devicons"
  },
  cmd = {
    "GitLabReviewMR",
  },
  build = function() require("gitlab.server").build(true) end,
  config = function()
    require("gitlab").setup({
      port = nil,                                               -- The port of the Go server, which runs in the background, if omitted or `nil` the port will be chosen automatically
      log_path = vim.fn.stdpath("cache") .. "/gitlab.nvim.log", -- Log path for the Go server
      config_path = nil,                                        -- Custom path for `.gitlab.nvim` file, please read the "Connecting to Gitlab" section
      debug = {
        go_request = false,
        go_response = false,
      },
      attachment_dir = nil, -- The local directory for files (see the "summary" section)
      reviewer_settings = {
        diffview = {
          imply_local = false, -- If true, will attempt to use --imply_local option when calling |:DiffviewOpen|
        },
      },
      connection_settings = {
        insecure = false,                      -- Like curl's --insecure option, ignore bad x509 certificates on connection
      },
      help = "g?",                             -- Opens a help popup for local keymaps when a relevant view is focused (popup, discussion panel, etc)
      popup = {                                -- The popup for comment creation, editing, and replying
        keymaps = {
          next_field = "<Tab>",                -- Cycle to the next field. Accepts count.
          prev_field = "<S-Tab>",              -- Cycle to the previous field. Accepts count.
        },
        perform_action = "<leader>s",          -- Once in normal mode, does action (like saving comment or editing description, etc)
        perform_linewise_action = "<leader>l", -- Once in normal mode, does the linewise action (see logs for this job, etc)
        width = "40%",
        height = "60%",
        border = "rounded", -- One of "rounded", "single", "double", "solid"
        opacity = 1.0,      -- From 0.0 (fully transparent) to 1.0 (fully opaque)
        comment = nil,      -- Individual popup overrides, e.g. { width = "60%", height = "80%", border = "single", opacity = 0.85 },
        edit = nil,
        note = nil,
        pipeline = nil,
        reply = nil,
        squash_message = nil,
        temp_registers = {}, -- List of registers for backing up popup content (see `:h gitlab.nvim.temp-registers`)
      },
      discussion_tree = { -- The discussion tree that holds all comments
        auto_open = true, -- Automatically open when the reviewer is opened
        switch_view = "S", -- Toggles between the notes and discussions views
        default_view = "discussions", -- Show "discussions" or "notes" by default
        blacklist = {}, -- List of usernames to remove from tree (bots, CI, etc)
        jump_to_file = "o", -- Jump to comment location in file
        jump_to_reviewer = "m", -- Jump to the location in the reviewer window
        edit_comment = "e", -- Edit comment
        delete_comment = "dd", -- Delete comment
        refresh_data = "a", -- Refreshes the data in the view by hitting Gitlab's APIs again
        reply = "r", -- Reply to comment
        toggle_node = "t", -- Opens or closes the discussion
        toggle_all_discussions = "T", -- Open or close separately both resolved and unresolved discussions
        toggle_resolved_discussions = "R", -- Open or close all resolved discussions
        toggle_unresolved_discussions = "U", -- Open or close all unresolved discussions
        keep_current_open = false, -- If true, current discussion stays open even if it should otherwise be closed when toggling
        publish_draft = "P", -- Publishes the currently focused note/comment
        toggle_resolved = "p", -- Toggles the resolved status of the whole discussion
        position = "left", -- "top", "right", "bottom" or "left"
        open_in_browser = "b", -- Jump to the URL of the current note/discussion
        copy_node_url = "u", -- Copy the URL of the current node to clipboard
        size = "20%", -- Size of split
        relative = "editor", -- Position of tree split relative to "editor" or "window"
        resolved = '✓', -- Symbol to show next to resolved discussions
        unresolved = '-', -- Symbol to show next to unresolved discussions
        tree_type = "simple", -- Type of discussion tree - "simple" means just list of discussions, "by_file_name" means file tree with discussions under file
        toggle_tree_type = "i", -- Toggle type of discussion tree - "simple", or "by_file_name"
        draft_mode = false, -- Whether comments are posted as drafts as part of a review
        toggle_draft_mode = "D", -- Toggle between draft mode (comments posted as drafts) and live mode (comments are posted immediately)
        winbar = nil -- Custom function to return winbar title, should return a string. Provided with WinbarTable (defined in annotations.lua)
        -- If using lualine, please add "gitlab" to disabled file types, otherwise you will not see the winbar.
      },
      choose_merge_request = {
        open_reviewer = true, -- Open the reviewer window automatically after switching merge requests
      },
      info = {                -- Show additional fields in the summary view
        enabled = true,
        horizontal = false,   -- Display metadata to the left of the summary rather than underneath
        fields = {            -- The fields listed here will be displayed, in whatever order you choose
          "author",
          "created_at",
          "updated_at",
          "merge_status",
          "draft",
          "conflicts",
          "assignees",
          "reviewers",
          "pipeline",
          "branch",
          "target_branch",
          "delete_branch",
          "squash",
          "labels",
        },
      },
      discussion_signs = {
        enabled = true,                          -- Show diagnostics for gitlab comments in the reviewer
        skip_resolved_discussion = false,        -- Show diagnostics for resolved discussions
        severity = vim.diagnostic.severity.INFO, -- ERROR, WARN, INFO, or HINT
        virtual_text = false,                    -- Whether to show the comment text inline as floating virtual text
        priority = 100,                          -- Higher will override LSP warnings, etc
        icons = {
          comment = "→|",
          range = " |",
        },
      },
      pipeline = {
        created = "",
        pending = "",
        preparing = "",
        scheduled = "",
        running = "",
        canceled = "↪",
        skipped = "↪",
        success = "✓",
        failed = "",
      },
      create_mr = {
        target = nil,          -- Default branch to target when creating an MR
        template_file = nil,   -- Default MR template in .gitlab/merge_request_templates
        delete_branch = false, -- Whether the source branch will be marked for deletion
        squash = false,        -- Whether the commits will be marked for squashing
        title_input = {        -- Default settings for MR title input window
          width = 40,
          border = "rounded",
        },
      },
      colors = {
        discussion_tree = {
          username = "Keyword",
          date = "Comment",
          chevron = "DiffviewNonText",
          directory = "Directory",
          directory_icon = "DiffviewFolderSign",
          file_name = "Normal",
        }
      }
    })

    vim.api.nvim_create_user_command("GitLabReviewMR",
      function()
        require('gitlab').choose_merge_request();
      end,
      {})
  end,
}
