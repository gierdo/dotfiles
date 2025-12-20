return {
  "folke/sidekick.nvim",
  config = function()
    sidekick = require("sidekick")
    sidekick.setup({
      nes = {
        enabled = false,
      },
      cli = {
        enabled = true,
        mux = {
          backend = "tmux",
          enabled = true,
        },
        tools = {
          amazon_q = { cmd = { "invalid_to_disable" } },
          kiro = { cmd = { "wrapped-kiro" } },
          opencode = { cmd = { "opencode" } },
        },
      },
    })

    -- Allow the lsp client to override the terminal mode when receiving showDocument requests
    local original_handler = vim.lsp.handlers["window/showDocument"]
    vim.lsp.handlers["window/showDocument"] = function(...)
      local args = { ... }

      -- Skip sidekick_terminal windows
      local current_buf = vim.api.nvim_get_current_buf()
      if vim.api.nvim_get_option_value("filetype", { buf = current_buf }) == "sidekick_terminal" then
        -- Find first normal text buffer window
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local win_buf = vim.api.nvim_win_get_buf(win)
          if
            vim.api.nvim_get_option_value("filetype", { buf = win_buf }) ~= "sidekick_terminal"
            and vim.api.nvim_get_option_value("buftype", { buf = win_buf }) == ""
          then
            vim.api.nvim_set_current_win(win)
            break
          end
        end
      end

      if vim.api.nvim_get_mode().mode == "t" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
        vim.defer_fn(function()
          original_handler(unpack(args))
        end, 10)
        return { success = true }
      end
      return original_handler(...)
    end
  end,
  cmd = {
    "Sidekick",
  },
  keys = {
    {
      "<A-a>",
      function()
        require("sidekick.cli").toggle({ filter = { installed = true } })
      end,
      desc = "Sidekick Toggle",
      mode = { "n", "t", "i" },
    },
    {
      "<A-a>",
      function()
        require("sidekick.cli").send({
          filter = { installed = true },
          msg = "The current file is {file}, this is the current selection: \n\n```\n{selection}\n```",
        })
      end,
      desc = "Sidekick Toggle with context",
      mode = { "x" },
    },
    {
      "<A-i>",
      function()
        require("sidekick.cli").prompt({ filter = { installed = true } })
      end,
      desc = "Sidekick Select Prompt",
      mode = { "n", "t", "i", "x" },
    },
  },
}
