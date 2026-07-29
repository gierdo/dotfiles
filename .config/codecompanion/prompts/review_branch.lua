local M = {}

local _branch

-- Exposed globally for input() completion callback
_G._review_branch_complete = function(lead, _, _)
  local out = vim.system({ "git", "branch", "--format=%(refname:short)" }, { text = true }):wait().stdout or ""
  return vim.tbl_filter(function(b)
    return b:find(lead, 1, true) ~= nil
  end, vim.split(out, "\n", { trimempty = true }))
end

function M.target_branch(args)
  _branch = vim.fn.input("Target branch: ", "main", "customlist,v:lua._review_branch_complete")
  if _branch == "" then
    _branch = "main"
  end
  return _branch
end

function M.diff(args)
  local target = _branch or "main"
  local base = vim.system({ "git", "merge-base", "HEAD", target }, { text = true }):wait().stdout:gsub("%s+$", "")
  return vim.system({ "git", "diff", "--no-ext-diff", base .. "..HEAD" }, { text = true }):wait().stdout
end

return M
