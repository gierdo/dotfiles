local utils = require("utils")

local function startLlama()
    os.execute('systemctl --user start llama')
end

local keymap_opts = { noremap = true, silent = true }

return {
    {
        'gierdo/neoai.nvim',
        branch = 'local-llama',
        keys = {
            {
                mode = "n",
                '<A-a>',
                function()
                    vim.cmd("NeoAI")
                end,
                keymap_opts
            },
            {
                mode = "n",
                '<A-i>',
                function()
                    vim.cmd('NeoAIInject<Space>')
                end,
                keymap_opts
            },

            {
                mode = "v",
                '<A-a>',
                function()
                    vim.cmd('NeoAIContext')
                end,
                keymap_opts
            },
            {
                mode = "v",
                '<A-i>',
                function()
                    vim.cmd('NeoAIInjectContext<Space>')
                end,
                keymap_opts
            }
        },
        config = function()
            startLlama()
            require("neoai").setup({
                ui = {
                    output_popup_text = "AI",
                    input_popup_text = "Prompt",
                    width = 45,               -- As percentage eg. 45%
                    output_popup_height = 80, -- As percentage eg. 80%
                    submit = "<Enter>",       -- Key binding to submit the prompt
                },
                models = {
                    {
                        name = "openai",
                        model = "codellama",
                        params = nil,
                    },
                },
                register_output = {
                    ["a"] = function(output)
                        return output
                    end,
                    ["c"] = require("neoai.utils").extract_code_snippets,
                },
                inject = {
                    cutoff_width = 75,
                },
                prompts = {
                    context_prompt = function(context)
                        return "I'd like to provide some context for future "
                            .. "messages. Here is what I want to refer "
                            .. "to in our upcoming conversations:\n\n"
                            .. context
                    end,
                },
                mappings = {
                    ["select_up"] = "<C-k>",
                    ["select_down"] = "<C-j>",
                },
                open_ai = {
                    url = "http://localhost:9741/v1/chat/completions",
                    display_name = "llama.cpp",
                    api_key = {
                        env = "OPENAI_API_KEY",
                        value = nil,
                        -- `get` is is a function that retrieves an API key, can be used to override the default method.
                        -- get = function() ... end

                        -- Here is some code for a function that retrieves an API key. You can use it with
                        -- the Linux 'pass' application.
                        -- get = function()
                        --     local key = vim.fn.system("pass show openai/mytestkey")
                        --     key = string.gsub(key, "\n", "")
                        --     return key
                        -- end,
                    },
                },
                shortcuts = {
                    --        {
                    --            name = "textify",
                    --            key = "<leader>as",
                    --            desc = "fix text with AI",
                    --            use_context = true,
                    --            prompt = [[
                    --                Please rewrite the text to make it more readable, clear,
                    --                concise, and fix any grammatical, punctuation, or spelling
                    --                errors
                    --            ]],
                    --            modes = { "v" },
                    --            strip_function = nil,
                    --        },
                    --        {
                    --            name = "gitcommit",
                    --            key = "<leader>ag",
                    --            desc = "generate git commit message",
                    --            use_context = false,
                    --            prompt = function()
                    --                return [[
                    --                    Using the following git diff generate a consise and
                    --                    clear git commit message, with a short title summary
                    --                    that is 75 characters or less:
                    --                ]] .. vim.fn.system("git diff --cached")
                    --            end,
                    --            modes = { "n" },
                    --            strip_function = nil,
                    --        },
                },
            })
        end,
        dependencies = {
            'MunifTanjim/nui.nvim',
        }

    },
    'MunifTanjim/nui.nvim',
}
