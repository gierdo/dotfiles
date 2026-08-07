return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
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

      local opts = function()
        -- ACP adapters: { adapter_name, executable }
        -- Add new CLI agents here to have them auto-detected
        local acp_agents = {
          { name = "kiro", executable = "kiro-cli" },
          {
            name = "agy-acp",
            executable = "agy-acp",
            adapter = function()
              return require("codecompanion.adapters.acp").extend("kiro", {
                name = "agy-acp",
                formatted_name = "Antigravity",
                commands = {
                  default = { "agy-acp" },
                },
              })
            end,
          },
          { name = "opencode", executable = "opencode" },
          -- { name = "codex", executable = "codex" },
          -- { name = "claude_code", executable = "claude" },
        }

        local acp = { opts = { show_presets = false }, defaults = { mcpServers = "inherit_from_config" } }
        local first_available
        for _, agent in ipairs(acp_agents) do
          if vim.fn.executable(agent.executable) == 1 then
            acp[agent.name] = agent.adapter or agent.name
            if not first_available then
              first_available = agent.name
            end
          end
        end

        local use_gemini = vim.env.GEMINI_API_KEY ~= nil

        return {
          display = {
            action_palette = {
              opts = {
                show_preset_prompts = false,
              },
            },
            chat = {
              intro_message = "Using AI for this may turn you into a 🦄 or a 🤡! Which will it be today?",
              window = {
                sticky = true,
              },
              show_reasoning = false,
            },
          },
          interactions = {
            chat = {
              adapter = use_gemini and "gemini" or (first_available or "kiro"),
              opts = {
                prompt_decorator = function(content, adapter)
                  -- The ACP adapter doesn't allow extending or overriding the system prompt. We have to inject what we want in the first user prompt.
                  if adapter.type ~= "acp" or adapter._cc_preprompt_sent then
                    return content
                  end
                  adapter._cc_preprompt_sent = true
                  local f = io.open(vim.fn.expand("~/.dotfiles/.config/codecompanion/system_prompt.md"), "r")
                  if not f then
                    return content
                  end
                  local prompt = f:read("*a")
                  f:close()
                  return prompt .. "\n\n---\n\n" .. content
                end,
              },
              editor_context = {
                ["buffer"] = {
                  opts = {
                    default_param = "diff",
                  },
                },
              },
            },
          },
          prompt_library = {
            markdown = {
              dirs = {
                "~/.dotfiles/.config/codecompanion/prompts",
              },
            },
          },
          adapters = {
            acp = acp,
            http = {
              gemini = function()
                return require("codecompanion.adapters").extend("gemini", {
                  schema = {
                    model = {
                      default = "gemini-3.6-flash",
                    },
                  },
                  env = {
                    api_key = "GEMINI_API_KEY",
                  },
                })
              end,
            },
          },
        }
      end

      require("codecompanion").setup(opts())

      vim.keymap.set({ "n", "t", "i" }, "<A-a>", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "CodeCompanion Toggle" })
      vim.keymap.set({ "x" }, "<A-a>", "<cmd>CodeCompanionChat Add<cr>", { desc = "CodeCompanion add selection" })
      vim.keymap.set(
        { "n", "t", "i", "x" },
        "<A-i>",
        "<cmd>CodeCompanionActions<cr>",
        { desc = "CodeCompanion Actions" }
      )
    end,
  },
}
