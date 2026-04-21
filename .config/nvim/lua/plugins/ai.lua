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
        mode = { "n", "t", "i" },
      },
      {
        "<A-a>",
        "<cmd>CodeCompanionChat Add<cr>",
        desc = "CodeCompanion Add Selection",
        mode = { "x" },
      },
      {
        "<A-i>",
        "<cmd>CodeCompanionActions<cr>",
        desc = "CodeCompanion Actions",
        mode = { "n", "t", "i", "x" },
      },
    },
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

      local acp = { opts = { show_presets = false } }
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
        mcp = {
          servers = {
            ["1mcp"] = {
              cmd = {
                "npx",
                "-y",
                "@1mcp/agent",
                "--transport=stdio",
                "--enable-auth",
              },
            },
          },
        },
      }
    end,
  },
}
