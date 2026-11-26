---
name: nvim-bridge
description: Ground rules and primitives for driving a live Neovim through the nvim-editor-mcp bridge - attaching to the right instance, turning async plugin calls into synchronous ones, returning JSON-safe values, avoiding prompts that hang the editor, and leaving the layout as you found it. Use whenever you call nvim_exec_lua, attach_nvim, open_file, set_quickfix, get_diagnostics, or notify: to run plugin APIs (nvim-dap, neotest, LSP, overseer, conform, oil), inspect or report editor state, or recover when a bridge call errors, times out, hangs, or returns EOF.
compatibility: Requires the nvim-editor-mcp MCP server (or Pi extension) and a running Neovim.
---

# Working over the Neovim bridge

`nvim-editor-mcp` exposes eight generic tools: `list_nvim_instances`,
`attach_nvim`, `detach_nvim`, `open_file`, `set_quickfix`, `get_diagnostics`,
`nvim_exec_lua`, `notify`. There is no per-plugin tool. `nvim_exec_lua` evaluates
Lua on Neovim's main loop and JSON-encodes whatever you return, which means the
entire plugin API surface is available to you - and every way that surface is
awkward (async, prompts, buffer state, UI side effects) lands on you.

These are the rules that hold for every plugin. `nvim-dap` is the worked example
in `~/.pi/agent/skills/nvim-dap/`.

## Attach, then look

`list_nvim_instances` first. With several instances running, pick one in the same
Herdr workspace as you, preferring the same working directory; `attach_nvim(socket=...)`
binds it. Never go hunting for sockets with shell commands. Then load the helper
(below) and orient before doing anything:

```lua
return Bridge.env()
```

Getting the instance wrong is expensive: you will read state from, and mutate, a
different editor than the human is looking at. If `env()` shows an unexpected
`cwd` or `current buffer`, detach and attach again rather than continuing.

## Load the helper

`scripts/bridge.lua` holds the primitives that every bridge task repeats. It
lives in `_G.Bridge` for the whole Neovim session, so load once per session:

```lua
-- nvim_exec_lua, once
local p = vim.fn.expand("$HOME/.pi/agent/skills/nvim-bridge/scripts/bridge.lua")
local f = assert(io.open(p))
return assert(load(f:read("a"), p))()
```

| Call | Use it for |
| --- | --- |
| `Bridge.env()` | First call, always: nvim version, pid, cwd, current buffer + filetype + modified + buftype, window/buffer/tabpage counts, mapleader, `switchbuf`, whether `dap`/`neotest`/`overseer` are require-able, which skill globals are live |
| `Bridge.await(fn, ms)` | Finish a call that suspends a coroutine until someone resumes it |
| `Bridge.cb(fn, ms)` | Finish a callback API: `fn(cb)` where `cb(err, result, ...)` |
| `Bridge.settle(pred, ms, label)` | Bounded wait that reports `settled` vs `TIMEOUT`, never silence |
| `Bridge.text(v)` | Flatten any table into a JSON-safe string |
| `Bridge.load(path)` | Run another file inside Neovim - how plugin skills install their helpers |
| `Bridge.layout_save(tag)` / `Bridge.layout_restore(tag)` | Snapshot and put back the human's windows (floats excluded) |
| `Bridge.ui_inventory()` | Windows, buffers, filetypes, cursors - notice windows you forgot to close |
| `Bridge.buf_dump(what, limit, from)` | Read a buffer as text: test output, HTTP responses, DAP panes, terminals |
| `Bridge.safe(fn, label)` | Wrap a callback so your failure cannot deafen the plugin |
| `Bridge.errors_report()` | Callback errors that were swallowed |
| `Bridge.assess()` / `Bridge.wipe(names...)` | Last call: editor back to where it started, globals cleared |

## Rule 1 - return scalars

The bridge JSON-encodes your return value, and it is pickier than Lua is used to:

- A table with **both** array and hash parts fails outright:
  `Cannot convert given Lua table`. Return one or the other, or `Bridge.text(t)`.
- A hole in an array (`{a, nil, b}`) or a `vim.NIL` sneaks `null` in where the
  schema wants a value.
- Lua `nil` passed into `vim.fn.*` becomes `v:null`, which many functions reject:
  `vim.fn.sign_getplaced(nil, {...})` gives `E158: Invalid buffer name`. Pass
  explicit values; don't rely on absent arguments.
- Strings always ship. When in doubt, `table.concat(lines, "\n")`.

## Rule 2 - async becomes synchronous

Neovim plugin APIs are overwhelmingly async. Inside one `nvim_exec_lua` call you
can still wait for the answer, because `vim.wait()` pumps the event loop while
Lua blocks:

```lua
-- coroutine shape: the API yields and something else resumes it
local res
local co = coroutine.create(function() res = { the_async_call() } end)
coroutine.resume(co)
if vim.wait(5000, function() return res ~= nil end, 10) then
  return Bridge.text(res)
end
```

`Bridge.await` and `Bridge.cb` wrap exactly this and add a verdict, so a timeout
reads as `TIMEOUT after 5000ms (callback never fired)` instead of a mysterious
empty result. Two details that bite:

- **Capture the coroutine before you schedule the resume.** `coroutine.running()`
  returns `false, true` on the main thread, so calling it inside the deferred
  callback resumes nothing. This is what nvim-dap's `coresume(co)` is for.
- **Bound every wait.** `vim.wait` does keep the editor responsive to the human,
  but your bridge call is in flight the whole time, so a long or unbounded wait
  looks like a hang from the outside and can hit the MCP client timeout. Use the
  smallest timeout that covers the operation and treat `TIMEOUT` as a real answer
  meaning "still running", not an error to retry blindly.

## Rule 3 - never cause a prompt

Anything that opens a picker, `vim.ui.select`, `vim.ui.input`, or `input()` waits
on the human *inside your synchronous call*. The bridge blocks until they answer,
and if nobody is watching, the session is effectively dead.

Before relying on an unfamiliar API, check whether it prompts. The practical
test is to scan the plugin's own Lua for the primitives:

```lua
local PLUGIN_NAME = "nvim-dap"
local dir = vim.fn.stdpath("data") .. "/lazy/" .. PLUGIN_NAME .. "/lua/"
local pats = { "vim.ui.select", "vim.ui.input", "vim.fn.input", "input(", "pick_one" }
local hits = {}
local function scan(d)
  for e in vim.fs.dir(d) do
    local p = d .. e
    if vim.fn.isdirectory(p) == 1 then scan(p)
    elseif p:match("%.lua$") then
      local f = io.open(p)
      if f then
        for line in f:lines() do
          for _, pat in ipairs(pats) do
            if line:find(pat, 1, true) then
              -- slice, not gsub: a path has pattern magic in it
              hits[#hits + 1] = p:sub(#dir + 1) .. ": " .. line:gsub("^%s+", ""):sub(1, 72)
              break
            end
          end
        end
        f:close()
      end
    end
  end
end
scan(dir)
return next(hits) and table.concat(hits, "\n") or ("no prompting primitives in " .. PLUGIN_NAME)
```

Prefer the API's explicit-argument path over its interactive one; that substitution
is the main reason per-plugin skills earn their keep. In `nvim-dap`,
`dap.continue()` opens a telescope config picker while `dap.run(config_table)`
never does.

Also note: opening `:help`, a telescope window, or any float changes the window
count under you. `Bridge.layout_save` deliberately ignores floats, and
`Bridge.ui_inventory` labels them, so transient notification windows (noice) do
not make you think you leaked a split.

## Rule 4 - it is somebody's editor

You are mutating a live session, not a scratch instance.

- `Bridge.layout_save()` before anything that opens, closes, or re-buffers
  windows; `Bridge.layout_restore()` after; `Bridge.assess()` as the final call
  to prove you got back to the start.
- Save the cursor position of the buffer you are about to move, if you move it.
- Unsaved changes matter: the Pi extension runs `:wall` and protects dirty
  buffers, so do not stomp a buffer the human is editing, and report unsaved
  files rather than writing them.
- `set_quickfix` and `:copen` own the quickfix list; `dap.list_breakpoints(true)`
  and other plugin commands rewrite it too. If something else (a `/qf` test-failure
  sync) may be using it, use a loclist or report locations in text instead.
- Clean up: delete buffers you created, `Bridge.wipe("Bridge", ...)` your globals,
  remove temp files. Namespace scratch globals (`Bridge`, `AgentDAP`,
  `AgentLayout`) so collisions are visible in `env()`.
- Tell the human what you did with `notify`, at phase boundaries. Silent editor
  mutation reads like the editor misbehaving.

## Rule 5 - callbacks you register must not throw

Event/listener dispatchers in plugins typically iterate registered callbacks with
`pairs()` and do not `pcall` them. So one listener that raises stops every later
listener for that event - including the plugin's own, which can make a UI go
quiet with no visible error. Two rules follow:

- Wrap your body: `Bridge.safe(my_fn, "my-label")`. Errors get recorded and are
  readable via `Bridge.errors_report()` instead of silently breaking others.
- Register under one namespace and remove it when done, or you leave a
  landmine for the next session: a leftover closure referencing a `_G` table that
  no longer exists will throw on every event forever. (Many dispatcher tables are
  lazily created; indexing a missing one returns `nil`, and `pairs(nil)` is a
  second classic error - check the namespace exists.)

## When something goes wrong

Short list; `references/troubleshooting.md` has the full symptom -> cause -> fix
table, including how to recover state after each.

| Symptom | Cause |
| --- | --- |
| `EOF` from `nvim_exec_lua`, then everything fails | nvim-side handler wedged; `detach_nvim` then `attach_nvim` |
| `Cannot convert given Lua table` | return value mixed array+hash; use `Bridge.text` |
| `v:null` / `E158` style errors | Lua `nil` into `vim.fn`; pass explicit values |
| `This event loop is already running` | nested loop run from inside a handler; use `Bridge.await`/`Bridge.cb` instead |
| Call hangs until the human acts | you triggered a picker or prompt |
| `TIMEOUT` from `await`/`cb` but no error | the resume was never scheduled, or you resumed from the main thread |
| Output or UI updates missing after your code ran | a listener threw and killed the chain; check `Bridge.errors_report()` |
| Config value looks wrong for a plugin | you read the defaults table instead of the merged effective config |
