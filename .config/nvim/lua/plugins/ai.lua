return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<A-a>",
        "<cmd>CodeCompanionChat Toggle<cr>",
        desc = "CodeCompanion Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<A-i>",
        "<cmd>CodeCompanionActions<cr>",
        desc = "CodeCompanion Actions",
        mode = { "n", "t", "i", "x" },
      },
    },
    init = function()
      -- If new buffers are opened or jumps being triggered while focus is on codecompanion, the action should be triggered outside of the codecompanion buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "codecompanion",
        callback = function(args)
          vim.bo[args.buf].buflisted = false
          local win = vim.fn.bufwinid(args.buf)
          if win == -1 then
            return
          end
          -- Guard this window: redirect any non-cc buffer that lands here
          vim.api.nvim_create_autocmd("BufWinEnter", {
            callback = function(ev)
              if not vim.api.nvim_win_is_valid(win) then
                return true
              end
              if vim.api.nvim_get_current_win() ~= win then
                return
              end
              if ev.buf == args.buf then
                return
              end
              -- Restore cc buffer in this window, move new buffer elsewhere
              vim.api.nvim_win_set_buf(win, args.buf)
              for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
                if w ~= win and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "codecompanion" then
                  vim.api.nvim_win_set_buf(w, ev.buf)
                  vim.api.nvim_set_current_win(w)
                  return
                end
              end
              vim.cmd("split | buffer " .. ev.buf)
            end,
          })
        end,
      })
    end,
    opts = function()
      -- ACP adapters: { adapter_name, executable }
      -- Add new CLI agents here to have them auto-detected
      local acp_agents = {
        { "kiro", "kiro-cli" },
        { "gemini_cli", "gemini" },
        -- { "opencode", "opencode" },
        -- { "codex", "codex" },
        -- { "claude_code", "claude" },
      }

      local acp = { opts = { show_presets = false }, defaults = { mcpServers = "inherit_from_config" } }
      local first_available
      for _, agent in ipairs(acp_agents) do
        if vim.fn.executable(agent[2]) == 1 then
          acp[agent[1]] = agent[1]
          if not first_available then
            first_available = agent[1]
          end
        end
      end

      return {
        interactions = {
          chat = {
            adapter = first_available or "kiro",
          },
        },
        adapters = {
          acp = acp,
        },
      }
    end,
  },
}
