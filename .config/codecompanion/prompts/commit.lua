local M = {}

function M.diff()
  return vim.system({ "git", "diff", "--no-ext-diff", "--staged" }, { text = true }):wait().stdout
end

return M
