# Portability: loading the helper from any harness

This skill is written against the [Agent Skills](https://agentskills.io)
convention: a directory with `SKILL.md` plus bundled `scripts/` and
`references/`. Nothing in it assumes Pi, and no path in the docs is absolute.

## Finding `<SKILL_DIR>`

Every bundled file is referenced relative to the skill directory. Your harness
knows where it loaded the skill from:

| Harness | Where the directory comes from |
|---|---|
| Pi | the `<available_skills>` entry for the skill has `location: .../SKILL.md`; the skill dir is its parent |
| Claude Code | reported when the skill is loaded (`~/.claude/skills/<name>/` for personal skills, `.claude/skills/` or `.agents/skills/` for project ones) |
| Any spec-compliant runner | the loader passes the skill path with the instructions |
| Unknown | resolve it yourself: `find ~ -type f -path '*nvim-bridge/scripts/bridge.lua' 2>/dev/null` |

Convention for the snippets below: substitute the real directory before sending
the code. Do not paste a literal `<SKILL_DIR>`, and do not bake a personal home
path into anything you write down - it breaks the next user and the next harness.

### If no harness reported it

Probe the standard locations from inside Neovim. This is a last resort, not a
substitute: the same file can exist under several roots (`~/.pi/agent/skills`,
`~/.claude/skills`, `~/.codex/skills` are all present on the machine this skill
was written on), and a copy in another harness's directory may be an older
version. Prefer the harness-reported path whenever you have one, and if the
probe returns more than one hit, check which is newest before loading.

```lua
local rel = "nvim-bridge/scripts/bridge.lua"
local roots = {
  os.getenv("HOME") .. "/.pi/agent/skills/",
  os.getenv("HOME") .. "/.claude/skills/",
  os.getenv("HOME") .. "/.codex/skills/",
  os.getenv("HOME") .. "/.agents/skills/",
  vim.fn.getcwd() .. "/.claude/skills/",
  vim.fn.getcwd() .. "/.agents/skills/",
}
local found = {}
for _, r in ipairs(roots) do
  local fh = io.open(r .. rel)
  if fh then fh:close() found[#found + 1] = r .. rel end
end
if #found == 0 then return "helper not found in " .. #roots .. " probed roots - use the inline tier" end
table.sort(found, function(a, b) return vim.fn.getftime(a) > vim.fn.getftime(b) end)
return "newest first:\n  " .. table.concat(found, "\n  ")
```

## Tier 1 - same machine (the normal case)

The bridge and Neovim share a filesystem, so the helper is read by Lua inside
Neovim. One call, and `_G.Bridge` then survives for the whole editor session:

```lua
local dir = "<SKILL_DIR>"
local p = dir .. "/scripts/bridge.lua"
local f = io.open(p)
if not f then return "no helper at " .. p .. " - check the skill dir, or use the inline tier" end
local chunk, lerr = load(f:read("a"), p)
f:close()
if not chunk then return "SYNTAX ERROR: " .. tostring(lerr) end
return chunk()
```

`Bridge.load(path)` does the same with better error text once Bridge exists, so
plugin helpers (`nvim-dap`'s `agent_dap.lua`) are one call:

```lua
return Bridge.load("<SKILL_DIR>/../nvim-dap/scripts/agent_dap.lua")
```

That relative-to-sibling form assumes both skills live in the same skills root,
which is typical but not guaranteed - if it fails, resolve each skill dir
independently.

## Tier 2 - no file access, or path unknown

If the agent cannot read files, or Neovim runs on another host, inline this
instead. It is a subset: `await`, `cb`, `text`, the layout pair, and `assess`.
Idempotent, so running it after a full load is harmless.

```lua
if not _G.Bridge then
  local B = {} _G.Bridge = B
  local function flat(v)
    if v == nil then return "nil" end
    if type(v) ~= "table" then return tostring(v) end
    local o = {} for k, x in pairs(v) do o[#o+1] = tostring(k) .. "=" .. flat(x) end
    table.sort(o) return "{" .. table.concat(o, " ") .. "}"
  end
  B.text = function(...) local p = {} for i = 1, select("#", ...) do p[i] = flat(select(i, ...)) end return table.concat(p, "\n") end
  local function verdict(res, ms, why)
    if not res then return "TIMEOUT after " .. ms .. "ms (" .. why .. ")", false end
    if res[1] ~= nil then return "ERROR: " .. flat(res[1]), false end
    if res[2] == nil then return "(no result)", true end
    if res[3] == nil then return flat(res[2]), true end
    local rest = {} for i = 2, #res do rest[#rest+1] = res[i] end return flat(rest), true
  end
  B.await = function(fn, ms)
    ms = ms or 4000
    local res
    local co = coroutine.create(function() res = { fn() } end)
    local ok, err = coroutine.resume(co)
    if not ok then return "ERROR in call: " .. tostring(err), false end
    -- inline the wait: a helper taking `res` by value closes over a copy and
    -- would always burn the full timeout
    vim.wait(ms, function() return res ~= nil end, 10)
    return verdict(res, ms, "never resumed")
  end
  B.cb = function(fn, ms)
    ms = ms or 4000
    local res
    local ok, err = pcall(fn, function(...) res = { ... } end)
    if not ok then return "ERROR invoking: " .. tostring(err), false end
    vim.wait(ms, function() return res ~= nil end, 10)
    return verdict(res, ms, "callback never fired")
  end
  B.settle = function(pred, ms, label)
    ms = ms or 4000
    if vim.wait(ms, pred, 10) then return "settled: " .. (label or "condition true") end
    return "TIMEOUT after " .. ms .. "ms waiting for " .. (label or "condition")
  end
  -- Rule 5: dispatchers iterate listeners with pairs() and never pcall, so one
  -- throwing callback silences every later one. Wrap yours.
  B.safe = function(fn, label)
    return function(...)
      local ok, err = pcall(fn, ...)
      if not ok then
        B.errors = B.errors or {}
        B.errors[#B.errors + 1] = tostring(label or "callback") .. ": " .. tostring(err):gsub("\n.*", "")
        if #B.errors > 20 then table.remove(B.errors, 1) end
      end
    end
  end
  B.errors_report = function()
    if not B.errors or #B.errors == 0 then return "no swallowed callback errors" end
    return #B.errors .. " swallowed: " .. table.concat(B.errors, " | ")
  end
  B.layout_save = function(tag)
    local s = {}
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(w).relative == "" then
        s[#s+1] = { win = w, buf = vim.api.nvim_win_get_buf(w), cursor = vim.api.nvim_win_get_cursor(w) }
      end
    end
    _G.AgentLayout = _G.AgentLayout or {} _G.AgentLayout[tag or "main"] = s
    return "layout saved: " .. #s .. " normal windows"
  end
  B.layout_restore = function(tag)
    local s = (_G.AgentLayout or {})[tag or "main"]
    if not s then return "no saved layout for " .. tostring(tag) end
    local n = 0
    for _, v in ipairs(s) do
      if vim.api.nvim_win_is_valid(v.win) then
        pcall(vim.api.nvim_win_set_buf, v.win, v.buf)
        if pcall(vim.api.nvim_win_set_cursor, v.win, v.cursor) then n = n + 1 end
      end
    end
    _G.AgentLayout[tag or "main"] = nil
    return "layout restored: " .. n .. " windows"
  end
  B.assess = function()
    return "windows=" .. #vim.api.nvim_list_wins() .. " buffers=" .. #vim.api.nvim_list_bufs()
      .. " layout pending=" .. tostring(next(_G.AgentLayout or {}) ~= nil)
      .. " | " .. B.errors_report()
  end
end
return "Bridge (inline tier) " .. _G.Bridge.assess()
```

Everything else in this skill is prose you can execute by hand: the async
pattern is 6 lines (Rule 2), and `Bridge.text` exists only to dodge the
mixed-table encoding failure.

## Tier 3 - persistent install, only if asked

Making the helper `require`-able from inside Neovim would remove the path
question entirely, but there is no clean default location. Verified on nvim
0.12.6 with a probe module:

- `~/.local/share/nvim/lua/agent/probe.lua` - not found by `require`
- `~/.local/share/nvim/site/after/lua/agent/probe.lua` - not found, and
  `site/after` was not even in `runtimepath` here
- `require("agent.probe")` fails with `module 'agent.probe' not found` from both

So a persistent install means a deliberate change to the user's runtimepath or
`package.path` - a config edit in someone else's editor. Propose it, do not do it
silently, and if they accept, put it somewhere namespaced (`.../lua/agent/`) and
tell them how to remove it.

## Remote or containerized Neovim

If the MCP server talks to a Neovim on another host, Tier 1 fails on `io.open`
and the whole skill still works via Tier 2 - the inline tier touches no
filesystem. Confirm before assuming:

```lua
return tostring(vim.uv.os_gethostname()) .. " / " .. tostring(vim.fn.getcwd())
```

Compare against your own host and working directory; a mismatch means file-based
tools are editing somewhere else than the editor you are driving, which is the
most expensive mistake available here.
