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
      local q_available = vim.fn.executable("q")

      local models = {}

      if q_available then
        table.insert(models, {
          name = "q",
          model = "q",
          params = { "--trust-all-tools" },
        })
      else
        startLlama()
        table.insert(models, {
          name = "openai",
          model = "llama 3",
          params = nil,
        })
      end

      require("neoai").setup({
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
          ["c"] = require("neoai.utils").extract_code_snippets,
        },
        inject = {
          cutoff_width = 75,
        },
        mappings = {
          ["select_up"] = "<C-k>",
          ["select_down"] = "<C-j>",
        },
        open_ai = {
          url = "http://127.0.0.1:9741/v1/chat/completions",
          display_name = "llama.cpp",
          api_key = {
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
