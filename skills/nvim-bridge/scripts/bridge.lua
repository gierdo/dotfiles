-- bridge.lua -- shared primitives for driving a live Neovim through the
-- nvim-editor-mcp bridge (nvim_exec_lua). Load once per Neovim session;
-- _G.Bridge survives across bridge calls.
--
-- Paths are relative to this skill's directory, which your harness reports; do
-- not hardcode a home or a harness-specific install path. From nvim_exec_lua:
--   local f = assert(io.open("<SKILL_DIR>/scripts/bridge.lua"))
--   return assert(load(f:read("a"), "bridge"))()
-- No path available at all? Use the inline tier in references/portability.md.
-- Every function returns a string (or a number/boolean for the predicates), so
-- the result always JSON-encodes across the bridge.

local B = {}
_G.Bridge = B

B.timeout = 4000

local function scalar(v, depth)
  depth = depth or 0
  if v == nil then return "nil" end
  if type(v) == "string" then return v end
  if type(v) == "number" or type(v) == "boolean" then return tostring(v) end
  if type(v) ~= "table" then return type(v) .. ": " .. tostring(v) end
  if depth > 3 then return "{...}" end
  local out = {}
  local keys = {}
  for k in pairs(v) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
  for _, k in ipairs(keys) do
    out[#out + 1] = tostring(k) .. "=" .. scalar(v[k], depth + 1)
  end
  return "{" .. table.concat(out, " ") .. "}"
end

--- Flatten anything into a single string. Use this whenever you want to return
--- a computed table: a table with both array and hash parts makes the bridge
--- fail with "Cannot convert given Lua table", and nil holes become vim.NIL.
function B.text(...)
  local parts = {}
  for i = 1, select("#", ...) do
    parts[i] = scalar((select(i, ...)))
  end
  return table.concat(parts, "\n")
end

--- Format a packed {err, result, ...} the way DAP/LSP/callback APIs deliver it.
local function results(res)
  if type(res) ~= "table" then return scalar(res) end
  if res[1] ~= nil then return "ERROR: " .. scalar(res[1]) end
  if res[2] == nil then
    for _ in pairs(res) do return scalar(res) end
    return "(no result)"
  end
  if res[3] == nil then return scalar(res[2]) end
  local rest = {}
  for i = 2, #res do rest[#rest + 1] = res[i] end
  return scalar(rest)
end

--- Await a call that yields the current coroutine until someone resumes it
--- (nvim-dap Session:request, plugin internals). Capture the coroutine before
--- scheduling the resume: coroutine.running() is false on the main thread.
function B.await(fn, ms)
  ms = ms or B.timeout
  local res
  local co = coroutine.create(function() res = { fn() } end)
  local ok, err = coroutine.resume(co)
  if not ok then return "ERROR in call: " .. tostring(err), false end
  if vim.wait(ms, function() return res ~= nil end, 10) then
    return results(res), true
  end
  return "TIMEOUT after " .. ms .. "ms (nothing resumed the coroutine)", false
end

--- Await a callback-style API: fn(cb) where cb receives (err, result, ...).
function B.cb(fn, ms)
  ms = ms or B.timeout
  local got
  local ok, err = pcall(fn, function(...) got = { ... } end)
  if not ok then return "ERROR invoking: " .. tostring(err), false end
  if vim.wait(ms, function() return got ~= nil end, 10) then
    return results(got), true
  end
  return "TIMEOUT after " .. ms .. "ms (callback never fired)", false
end

--- Bounded wait on a predicate. Always returns a verdict - a bare vim.wait
--- timeout reads like a hang, this says which branch happened.
function B.settle(pred, ms, label)
  ms = ms or B.timeout
  local ok = vim.wait(ms, pred, 10)
  if ok then return "settled: " .. (label or "condition true") end
  return "TIMEOUT after " .. ms .. "ms waiting for " .. (label or "condition")
end

--- Load and run a Lua file inside Neovim; returns the chunk's own message.
--- The way plugin-specific helpers get installed from a skill directory.
function B.load(path)
  local f = io.open(path)
  if not f then return "cannot open " .. path end
  local src = f:read("a"); f:close()
  local chunk, lerr = load(src, path)
  if not chunk then return "SYNTAX ERROR: " .. tostring(lerr) end
  local ok, res = pcall(chunk)
  if not ok then return "RUNTIME ERROR: " .. tostring(res) end
  return "loaded " .. path:gsub(".*/", "") .. ": " .. tostring(res)
end

--- Environment snapshot: run this first, and again when anything looks wrong.
--- A wedge or a wrong-instance attach shows up here immediately.
function B.env()
  local out = {}
  out[#out + 1] = "nvim " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch
    .. " | pid " .. tostring(vim.fn.getpid()) .. " | cwd " .. vim.fn.getcwd()
  local cur = vim.api.nvim_get_current_buf()
  out[#out + 1] = "current buffer: " .. (vim.api.nvim_buf_get_name(cur) or "(none)")
    .. " ft=" .. vim.bo[cur].filetype .. " modified=" .. tostring(vim.bo[cur].modified)
    .. " buftype=" .. (vim.bo[cur].buftype == "" and "normal" or vim.bo[cur].buftype)
  out[#out + 1] = "windows=" .. #vim.api.nvim_list_wins() .. " tabpages=" .. #vim.api.nvim_list_tabpages()
    .. " buffers=" .. #vim.api.nvim_list_bufs()
  local listed = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.buflisted(b) == 1 then listed[#listed + 1] = vim.api.nvim_buf_get_name(b):gsub(".*/", "") end
  end
  out[#out + 1] = "listed: " .. table.concat(listed, ", ")
  out[#out + 1] = "mapleader=" .. tostring(vim.g.mapleader or "\\")
    .. " switchbuf=" .. tostring(vim.o.switchbuf)
  out[#out + 1] = "nvim-dap present=" .. tostring(pcall(require, "dap"))
    .. " neotest present=" .. tostring(pcall(require, "neotest"))
    .. " overseer present=" .. tostring(pcall(require, "overseer"))
  local ns = {}
  for _, k in ipairs({ "Bridge", "AgentDAP", "AgentLayout" }) do
    if _G[k] then ns[#ns + 1] = k end
  end
  out[#out + 1] = "skill globals live: " .. (next(ns) and table.concat(ns, ", ") or "none")
  return table.concat(out, "\n")
end

--- What is on screen, for reporting position to a human or noticing that you
--- added a window you forgot to close.
function B.ui_inventory()
  local lines = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local b = vim.api.nvim_win_get_buf(w)
    local c = vim.api.nvim_win_get_cursor(w)
    local cfg = vim.api.nvim_win_get_config(w)
    lines[#lines + 1] = string.format("win=%d %-6s ft=%-12s buf=%-28s cur=%d:%d", w,
      cfg.relative ~= "" and "(float)" or "", vim.bo[b].filetype,
      (vim.api.nvim_buf_get_name(b):gsub(".*/", "")) ..
      (vim.bo[b].buftype ~= "" and ("(" .. vim.bo[b].buftype .. ")") or ""), c[1], c[2])
  end
  return table.concat(lines, "\n")
end

--- Save / restore the human's layout around anything that moves windows.
--- Floats are skipped: notification popups (noice) and hover windows come and
--- go on their own, and counting them as layout makes the snapshot lie.
local function normal_windows()
  local out, floats = {}, 0
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(w).relative == "" then
      out[#out + 1] = { win = w, buf = vim.api.nvim_win_get_buf(w), cursor = vim.api.nvim_win_get_cursor(w) }
    else
      floats = floats + 1
    end
  end
  return out, floats
end

function B.layout_save(tag)
  local saved, floats = normal_windows()
  _G.AgentLayout = _G.AgentLayout or {}
  _G.AgentLayout[tag or "main"] = saved
  return "layout saved: " .. #saved .. " normal windows" .. (floats > 0 and (", " .. floats .. " floats skipped") or "")
end

function B.layout_restore(tag)
  local saved = (_G.AgentLayout or {})[tag or "main"]
  if not saved then return "no saved layout for tag " .. tostring(tag) end
  local moved, lost = 0, 0
  for _, sv in ipairs(saved) do
    if vim.api.nvim_win_is_valid(sv.win) then
      pcall(vim.api.nvim_win_set_buf, sv.win, sv.buf)
      local ok = pcall(vim.api.nvim_win_set_cursor, sv.win, sv.cursor)
      if ok then moved = moved + 1 else lost = lost + 1 end
    else
      lost = lost + 1
    end
  end
  _G.AgentLayout[tag or "main"] = nil
  if next(_G.AgentLayout) == nil then _G.AgentLayout = nil end
  return "layout restored: " .. moved .. " windows, " .. lost .. " gone"
end

--- Read a buffer as text: test output, HTTP response bodies, terminal pans,
--- DAP panes. Match by name substring, path, or exact buffer number.
function B.buf_dump(what, limit, from)
  local bufnr
  if type(what) == "number" then
    bufnr = what
  else
    for _, b in ipairs(vim.api.nvim_list_bufs()) do
      local nm = vim.api.nvim_buf_get_name(b)
      if nm ~= "" and nm:find(what, 1, true) then bufnr = b break end
    end
  end
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then return "no buffer matching " .. tostring(what) end
  if not vim.api.nvim_buf_is_loaded(bufnr) then pcall(vim.fn.bufload, bufnr) end
  local lines = vim.api.nvim_buf_get_lines(bufnr, (from or 1) - 1, (from or 1) - 1 + (limit or 120), false)
  for i, l in ipairs(lines) do lines[i] = string.format("%d| %s", (from or 1) + i - 1, l) end
  return vim.api.nvim_buf_get_name(bufnr) .. " (ft=" .. vim.bo[bufnr].filetype .. ", "
    .. #vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) .. " lines)\n" .. table.concat(lines, "\n")
end

--- Wrap a callback/listener body so your code cannot break other consumers.
--- Many dispatchers iterate with pairs() and never pcall: one throwing listener
--- stops every later one, including the plugin's own.
function B.safe(fn, label)
  return function(...)
    local ok, err = pcall(fn, ...)
    if not ok then
      B.errors = B.errors or {}
      B.errors[#B.errors + 1] = tostring(label or "callback") .. ": " .. tostring(err):gsub("\n.*", "")
      if #B.errors > 20 then table.remove(B.errors, 1) end
    end
  end
end

function B.errors_report()
  if not B.errors or #B.errors == 0 then return "no swallowed callback errors" end
  return #B.errors .. " swallowed callback errors (a plugin may look deaf):\n  " .. table.concat(B.errors, "\n  ")
end

--- Drop skill globals from _G when finished.
function B.wipe(...)
  local names = {}
  for _, n in ipairs({ ... }) do
    _G[n] = nil
    names[#names + 1] = n
  end
  return "wiped _G: " .. table.concat(names, ", ") .. " | still live: "
    .. (function()
      local l = {}
      for _, k in ipairs({ "Bridge", "AgentDAP", "AgentLayout" }) do if _G[k] then l[#l + 1] = k end end
      return next(l) and table.concat(l, ", ") or "none"
    end)()
end

--- Confirm the editor came back the way you found it. Run as the last call of
--- any session that touched windows or buffers.
function B.assess()
  local dirty = {}
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].modified and vim.fn.buflisted(b) == 1 then
      dirty[#dirty + 1] = vim.api.nvim_buf_get_name(b):gsub(".*/", "")
    end
  end
  return "windows=" .. #vim.api.nvim_list_wins() .. " buffers=" .. #vim.api.nvim_list_bufs()
    .. " tabpages=" .. #vim.api.nvim_list_tabpages()
    .. " | unsaved listed buffers: " .. (next(dirty) and table.concat(dirty, ", ") or "none")
    .. " | layout pending restore: " .. tostring(_G.AgentLayout ~= nil)
    .. "\n" .. B.errors_report()
end

return "Bridge ready (" .. #vim.api.nvim_list_wins() .. " windows)"
