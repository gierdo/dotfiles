local function startLlama()
  os.execute("systemctl --user start llama")
end

local keymap_opts = { expr = true }

return {
  {
    "gierdo/neoai.nvim",
    branch = "main",
    cmd = {
      "NeoAI",
      "NeoAIOpen",
      "NeoAIClose",
      "NeoAIToggle",
      "NeoAIContext",
      "NeoAIContextOpen",
      "NeoAIContextClose",
      "NeoAIInject",
      "NeoAIInjectCode",
      "NeoAIInjectContext",
      "NeoAIInjectContextCode",
    },
    keys = {
      {
        mode = "n",
        "<A-a>",
        ":NeoAI<CR>",
        keymap_opts,
      },
      {
        mode = "n",
        "<A-i>",
        ":NeoAIInject<Space>",
        keymap_opts,
      },

      {
        mode = "v",
        "<A-a>",
        ":NeoAIContext<CR>",
        keymap_opts,
      },
      {
        mode = "v",
        "<A-i>",
        ":NeoAIInjectContext<Space>",
        keymap_opts,
      },
    },
    config = function()
      local q_available = vim.fn.executable("q") == 1

      local models = {}
      local extract_code_snippets

      if q_available then
        extract_code_snippets = function(text)
          local matches = {}
          -- Amazon Q marks code by color-coding it green with ansi codes.
          -- Everything between "start green" and "reset color" is assumed to be code.
          for match in string.gmatch(text, "\27%[38;5;%d+m(.-)\27%[0m") do
            table.insert(matches, match)
          end
          return table.concat(matches, "\n\n")
        end

        table.insert(models, {
          name = "q",
          model = "q",
          params = { "--trust-all-tools" },
        })
      else
        startLlama()

        extract_code_snippets = function(text)
          local matches = {}
          for match in string.gmatch(text, "```%w*\n(.-)```") do
            table.insert(matches, match)
          end

          -- Next part matches any code snippets that are incomplete
          local count = select(2, string.gsub(text, "```", "```"))
          if count % 2 == 1 then
            local pattern = "```%w*\n([^`]-)$"
            local match = string.match(text, pattern)
            table.insert(matches, match)
          end
          return table.concat(matches, "\n\n")
        end

        table.insert(models, {
          name = "openai",
          model = "llama 3",
          params = nil,
        })
      end

      require("neoai").setup({ ---@diagnostic disable-line: missing-fields
        ui = {
          output_popup_text = "AI",
          input_popup_text = "Prompt",
          width = 45, -- As percentage eg. 45%
          output_popup_height = 80, -- As percentage eg. 80%
          submit = "<Enter>", -- Key binding to submit the prompt
        },
        models = models,
        register_output = {
          ["a"] = function(output)
            return output
          end,
          ["c"] = extract_code_snippets,
        },
        inject = {
          cutoff_width = 75,
        },
        prompts = {
          context_prompt = function(context)
            return "Please only follow instructions or answer to questions. Be concise. "
              .. (vim.api.nvim_buf_get_name(0) ~= "" and "This is my currently opened file: " .. vim.api.nvim_buf_get_name(
                0
              ) or "")
              .. "I'd like to provide some context for future "
              .. "messages. Here is the code/text that I want to refer "
              .. "to in our upcoming conversations:\n\n"
              .. context
          end,
          default_prompt = function()
            return "Please only follow instructions or answer to questions. Be concise. "
              .. (
                vim.api.nvim_buf_get_name(0) ~= ""
                  and "This is my currently opened file: " .. vim.api.nvim_buf_get_name(0)
                or ""
              )
          end,
        },
        mappings = {
          ["select_up"] = "<C-k>",
          ["select_down"] = "<C-j>",
        },
        open_ai = {
          url = "http://127.0.0.1:9741/v1/chat/completions",
          display_name = "llama.cpp",
          api_key = { ---@diagnostic disable-line: missing-fields
            value = nil,
            get = function()
              return ""
            end,
          },
        },
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "m00qek/baleia.nvim",
    },
  },
  { "MunifTanjim/nui.nvim", lazy = true },
}
