---
name: nvim-dap
description: Steer a live nvim-dap debugging session in the user's running Neovim through the nvim-editor-mcp bridge: set and verify breakpoints, launch, step, inspect frames and variables, evaluate expressions, capture program output, and restore the editor afterwards. Use whenever the user wants to debug, step through, reproduce, or investigate a runtime bug while Neovim is open, mentions dap, breakpoints, debugpy, delve, cppdbg, the DAP pane, or "debug this in vim", or wants to watch while an agent drives a debugger.
compatibility: Requires the nvim-editor-mcp MCP tools and a Neovim running mfussenegger/nvim-dap. Verified against nvim 0.12.6, nvim-dap with nvim-dap-view.
---

# Driving nvim-dap from an agent

There is no DAP tool. `nvim-editor-mcp` exposes only `list_nvim_instances`,
`attach_nvim`, `detach_nvim`, `open_file`, `set_quickfix`, `get_diagnostics`,
`nvim_exec_lua`, and `notify`. Everything debugger-related happens by evaluating
Lua against `require("dap")` inside the editor. That is not a limitation - it is
the whole surface of nvim-dap, including the parts the UI itself uses.

## Three facts that make this work

**1. Async becomes synchronous inside one bridge call.** nvim-dap is entirely
callback-driven, but `Session:request(cmd, args)` called *without* a callback
yields the current coroutine (`dap/session.lua:1887-1915`), and nvim-dap resumes
it from `vim.schedule` when the adapter answers. `vim.wait()` pumps the event
loop, so it resumes inside your call. One bridge call can therefore issue a
request, wait for it, and return the answer.

**2. Everything the human needs already happens on its own.** With the usual
nvim-dap + nvim-dap-view setup, a breakpoint hit automatically: opens the DAP
pane, jumps a window to the stopped frame, places the `DapStopped` sign, and
renders inline variable values via virtual text. You do not have to build a UI.
You have to keep it honest and keep the session shared.

**3. `stopped_thread_id` plus `current_frame` is the only reliable "stopped"
signal.** nvim-dap sets `session.stopped_thread_id` *before* it fetches the
stack, and `session.current_frame` only after the `stackTrace` round-trip inside
`Session:event_stopped` (`dap/session.lua:749-800`). Waiting on
`stopped_thread_id` alone - or on `thread.frames`, which survives a continue -
returns you a half-settled session with a nil frame. This is the single most
common way to get confused here.

## Load the helper once

Hand-written Lua per step re-derives all of the above every time and is where
mistakes come from. `scripts/agent_dap.lua` wraps it in string-returning
functions. The `_G.AgentDAP` table survives across bridge calls for the whole
Neovim session, so install once and reuse.

```lua
-- nvim_exec_lua, once. Adjust the path if this skill lives elsewhere.
local p = vim.fn.expand("$HOME/.pi/agent/skills/nvim-dap/scripts/agent_dap.lua")
local f = assert(io.open(p))
return assert(load(f:read("a"), p))() .. " / " .. AgentDAP.install()
```

Then each step is short and readable:

```lua
-- each line below is its own nvim_exec_lua call
return AgentDAP.state()                                  -- snapshot
return AgentDAP.bp("/abs/path/file.py", 42, { condition = "i > 3" })
return AgentDAP.run({ type = "python", request = "launch", name = "agent",
                      program = "/abs/path/file.py", args = {},
                      console = "internalConsole", justMyCode = true }, 25000)
return AgentDAP.frames() .. "\n" .. AgentDAP.locals(2)
return AgentDAP.eval("len(items) * 2")
return AgentDAP.step("over", 10000)
return AgentDAP.cont(30000)
return AgentDAP.terminate()
```

`AgentDAP` returns strings on purpose: a Lua table mixing array and hash parts
makes the bridge fail with `Cannot convert given Lua table`, and every debug
answer is meant to be read, not re-parsed.

Read `references/api.md` for the full function list and the raw nvim-dap calls
 underneath. Read `references/ui.md` before touching windows, watches, or the
quickfix list. Read `references/languages.md` for launch configs per language.

## The loop

1. **Attach.** `list_nvim_instances`, then `attach_nvim(socket=...)` on the
   instance in the same Herdr workspace and working directory. Confirm the
   filetype and buffer the human is actually looking at before debugging it.
2. **Preflight.** `AgentDAP.preflight(ftype)` lists registered adapters and
   preset configurations and checks the adapter binary exists. A mason
   `ensure_installed` entry does not imply a registered adapter, and some
   entries are lazy functions (nvim-dap-go).
3. **Breakpoints.** `AgentDAP.bp(path, line, {condition=, hit=, log=})`. This
   uses `dap.breakpoints.set(opts, bufnr, lnum)`, which works on unloaded and
   off-screen buffers, persists the intent so the plugin's auto-load cannot wipe
   it, and auto-syncs to a live session.
4. **Launch.** `AgentDAP.run(config)`, with the config table written out
   explicitly. Never `dap.continue()` on a cold start.
5. **Inspect.** `state`, `frames`, `locals(depth)`, `eval(expr)`, `threads`.
6. **Drive.** `step("over"|"into"|"out"|"back")`, `cont`, `up`/`down`, `rewind`,
   `exception_breaks`.
7. **Report**, then **teardown**: `terminate`, `clear_bps`, `uninstall`, restore
   the layout you saved.

## Keep the human in the loop

This is a shared session, not a headless harness. Before the first
window-mutating call, save the layout (`references/ui.md` has the matching
restore snippet, which also drops leftover `dap-repl` buffers):

```lua
local saved = {}
for _, w in ipairs(vim.api.nvim_list_wins()) do
  table.insert(saved, { win = w, buf = vim.api.nvim_win_get_buf(w), cursor = vim.api.nvim_win_get_cursor(w) })
end
_G.AgentLayout = saved
return #saved
```

and after teardown put it back with `nvim_win_set_buf` + `nvim_win_get_cursor`
/`nvim_win_set_cursor`. Then:

- **Re-read state before every action.** The human has real keymaps and will use
  them (`<leader>dc` continue, `<leader>dbt` toggle breakpoint, `<leader>dr` run
  to cursor, the DAP pane's winbar controls). They can step past where you
  thought you were, or terminate. `AgentDAP.state()` is cheap; assuming is not.
- **Tell them what you are doing.** `notify` posts into their editor, so a short
  line per milestone - launching, stopped where, finishing - costs nothing and
  stops them fighting your breakpoints.
- **Long waits do not freeze them.** `vim.wait` processes user events, so they
  can keep typing while you wait. Still bound every wait: the bridge call is
  in flight, and an unbounded one looks like a hang.
- **Their state is yours to read, not to reset.** Watches survive a session, so
  a stale `watched_expressions` may be theirs. Ask before clearing.
- **Use `set_quickfix` for your own findings** rather than
  `dap.list_breakpoints(true)`, which overwrites the quickfix list (it reuses
  the title-tagged list) and would clobber test failures from `/qf`.
- `open_file(path, line)` is the polite way to show them a frame or a caller;
  it moves them to the source without you re-implementing `switchbuf`.

## What hangs, and why

Anything that opens a picker or prompt waits on the *human* inside a synchronous
RPC call, so the bridge stalls until they act. The traps in this stack:

| Call | Problem |
|---|---|
| `dap.continue()` with no session | `select_config_and_run()` opens a telescope config picker (`dap.lua:1139-1146`) |
| `dap.run()` without a config table | asserts; `dap.run_last()` needs a prior run |
| `dap.focus_frame()` with no frame | opens a centered threads float (`dap.lua:694-700`) - use `AgentDAP.show_frame()` |
| `dap.set_breakpoint(cond, hit, log)` | cursor-line only; no `lnum`/`bufnr` (`dap.lua:1011`) |
| `dapbp_api.set_breakpoint` / `set_conditional_breakpoint` / `set_log_point` | `vim.ui.select` / `vim.ui.input` prompts |
| `dap.run_to_cursor()` | calls `breakpoints.clear()` and installs a temp breakpoint; wipes the set mid-flight (`dap.lua:1094-1108`) |
| `python` config `Python: Launch file with arguments` | `vim.fn.input("Arguments: ")` |
| `:help`, `:Telescope`, `vim.ui.*` | not DAP, but same hang, and they add windows you must clean up |

If a call returns `EOF`, the nvim-side handler is wedged: `detach_nvim`, then
`attach_nvim` again. That recovered it every time here.

## Failure modes worth knowing

- A listener that returns a truthy value **self-unregisters** (`call_listener`
  does `if remove then listeners[key] = nil end`, `dap/session.lua:1069-1077`).
  Return nothing for a persistent listener, `true` for one-shot.
- `call_listener` iterates with `pairs()` and does **not** `pcall`. One throwing
  listener silently kills every later listener for that event - including
  dap-view's. Observed: a leftover agent listener closing over a deleted `_G`
  table swallowed all `event_output` delivery for the rest of the nvim session.
  Register under one namespace, remove it in teardown, and check
  `AgentDAP.listeners()` when output or UI updates look missing.
- Breakpoints added through `dap.breakpoints.set` are invisible to a running
  adapter until `session:set_breakpoints(bps)` with the shape
  `{[bufnr] = {bp, ...}}`. Pass the flat list and it no-ops silently.
  `AgentDAP.bp` / `AgentDAP.sync` handle it; `A.bps()` shows `verified`,
  `unsynced`, or `REJECTED`.
- **Breakpoints can be wiped out from under you.** This config runs
  `dap-breakpoints.nvim` with `auto_load = true`, so `BufReadPost` triggers
  `load_breakpoints()` -> `persistent-breakpoints.reload_breakpoints()` ->
  `breakpoints.clear()` + restore from the on-disk store. Launching a debuggee
  loads its source buffer, so a breakpoint set through raw `dap.breakpoints.set`
  (which never reaches that store) can vanish mid-launch. Symptom worth
  remembering: the stop looks strange - `<module> @ file:0`, empty locals,
  `hitBreakpointIds = { 0 }` - and `bp.get()` is empty. It is not the code being
  odd; the breakpoint is gone. `AgentDAP` keeps the intended set in
  `A.wanted`, writes it through `save_breakpoints({notify="never"})`, and
  `AgentDAP.run` reports `ok: N/N intended breakpoints placed` or re-applies.
  Doing this by hand: set, persist, launch, then verify the count again.
- `justMyCode = false` (and step-into) loads library sources into real buffers -
  a `runpy.py` buffer appeared here and needed deleting at teardown. Prefer
  `justMyCode = true` unless you need the stdlib frames.
- Program output is not readable from the editor UI. It arrives as `event_output`
  DAP events; the helper keeps a ring buffer you can dump with `AgentDAP.tail(n)`.
  Use `console = "internalConsole"` for agent-driven runs (it also renders in the
  DAP pane for the human). A program needing stdin wants `integratedTerminal`.
- `dap.status()` can be stale ("Starting adapter python" mid-session). Trust
  `dap.session()`, `stopped_thread_id`, and `current_frame`.
- `vim.fn` calls receive Lua `nil` as `v:null`, which errors on optional args
  (`sign_getplaced(nil, ...)` -> E158). Pass explicit values.
- Namespace your globals (`_G.AgentDAP`, `_G.AgentLayout`) and clear them.
