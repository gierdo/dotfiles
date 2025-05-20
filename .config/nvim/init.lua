-- bootstrap lazy

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.cmd.set("shortmess=I")

require("config_d")
local lazy = require("lazy")
lazy.setup("plugins")

local function get_selected_text()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    return ""
  end

  -- Handle selection within a single line
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
  else
    -- Adjust first and last line for partial selections
    lines[1] = string.sub(lines[1], start_pos[3])
    lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
  end

  return table.concat(lines, "\n")
end

-- Function to send selected text to Amazon Q and display response
function amazon_q_query()
  local selected_text = get_selected_text()

  -- Create a temporary file to store the selected text
  local temp_file = os.tmpname()
  local file = io.open(temp_file, "w")
  file:write(selected_text)
  file:close()

  -- Send to Amazon Q CLI and get response
  local command = string.format("cat %s | q chat", temp_file)
  local response = vim.fn.system(command)

  -- Clean up temp file
  os.remove(temp_file)

  -- Display the response in a new buffer
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(response, "\n"))
  vim.cmd("setlocal buftype=nofile")
  vim.cmd("setlocal bufhidden=hide")
  vim.cmd("setlocal filetype=markdown")
end

-- Set up key mapping for visual mode
vim.api.nvim_set_keymap("v", "<leader>q", ":<C-u>lua amazon_q_query()<CR>", { noremap = true, silent = true })
