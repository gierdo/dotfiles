# API reference

Two layers: the `AgentDAP` helper (preferred) and the raw nvim-dap surface it
wraps (use when the helper does not cover something).

## AgentDAP

All functions return a string unless noted. Errors come back as text, not
exceptions, so a failed call still tells you what happened.

### Lifecycle

| Call | Meaning |
|---|---|
| `install()` | Register listeners under namespace `agent`; idempotent |
| `uninstall()` | Remove those listeners (keeps captured state) |
| `listeners()` | Who is registered on each event - diagnose swallowed output |
| `mark()` | Snapshot `{stopped, ended}` before an operation |
| `settled(ms, mark)` | Wait for the stop after that mark, or for the program to end. Returns `settled: <where>`, `program ended (exit=N)`, or `TIMEOUT` with `state()` appended |
| `state()` | Full snapshot: config, adapter, threads, frame, stop reason, capabilities, event counters, placed vs intended breakpoints, output tail |
| `exit_code` | Field, set on `event_exited` |

### Position and data

| Call | Meaning |
|---|---|
| `where()` | One line: `func @ /abs/path:line:col` |
| `frames()` | Stopped thread's stack, `>` marks the current frame |
| `threads()` | id, name, stopped flag, frame count per thread |
| `locals(depth, ms)` | Scopes and variables of the current frame; `depth=2` expands containers |
| `eval(expr, context, ms)` | Evaluate against the current frame's `frameId`; `context` defaults to `repl` |
| `assign(name, value, ms)` | `setVariable` in the first scope; needs `supportsSetVariable` and a populated scope handle, so call `locals()` first |
| `tail(n)` | Last n captured output lines |
| `ui_text(limit)` | Text of the dap-view pane - what the human is looking at |

### Breakpoints

| Call | Meaning |
|---|---|
| `bp(path, line, opts)` | Set; `opts = {condition=, hit=, log=}`; records intent, persists, auto-syncs if a session is live |
| `ubp(path, line)` | Remove (also from the intended set); buffer must be loaded |
| `apply()` | Re-place every intended breakpoint, persist, sync |
| `verify()` | Intended vs placed; re-applies and reports `MISSING ...` if wiped |
| `persist()` | Push the current set to the `dap-breakpoints` disk store |
| `sync(ms)` | Push local breakpoints into the live session |
| `bps()` | List with `verified` / `pending` / `unsynced` / `REJECTED` |
| `bp_count()` / `wanted_count()` | Placed / intended counts (numbers) |
| `clear_bps()` | Remove all, including intent, then persist and sync |
| `probe(path, {lines})` | Stage several candidate lines at once, to see which the adapter verifies |

### Execution

| Call | Meaning |
|---|---|
| `run(config, ms)` | Launch with an explicit config table, wait for the first settled stop or exit |
| `cont(ms)` | Continue to the next stop; says so if it was already running |
| `step(kind, ms)` | `over` / `into` / `out` / `back`; refuses `back` without `supportsStepBack` |
| `pause()` | Pause a running target |
| `up(n)` / `down(n)` | Walk the call stack, returns the new frame |
| `rewind(ms)` | `restartFrame`, if supported |
| `goto_line(line)` | `goto`, if supported |
| `exception_breaks(filters, ms)` | Break on thrown exceptions; `{ "all" }` default |
| `terminate(ms)` | End the session, leave the UI alone |
| `close_ui(hide_terminal)` | Close dap-view panes |

### Adapter inspection

| Call | Meaning |
|---|---|
| `preflight(ftype)` | Adapter presence, binary on PATH, preset configs |
| `adapters()` | Registered adapter keys (array) |

## Raw nvim-dap

`dap.adapters` maps a type to an adapter: either a table
(`{ type = "executable", command = ..., args = ... }`) or a lazy function.
`dap.configurations` maps a *filetype* to a list of config tables; each config
must carry `type` to link up to an adapter.

```lua
-- shape sketch, not a runnable chunk
local dap = require("dap")
dap.session()            -- focused session or nil
dap.sessions()           -- table keyed by session id
dap.set_session(s)       -- focus another session
dap.status()             -- human string; can lag the truth
dap.run(config, opts)    -- config must be a table; opts = { new = bool }
dap.run_last()
dap.continue(opts)       -- opens a picker when there is no session
dap.pause(), dap.step_over(), dap.step_into(), dap.step_out(), dap.step_back()
dap.up(), dap.down(), dap.restart_frame(), dap.focus_frame()
dap.run_to_cursor()      -- clears all breakpoints first - avoid
dap.goto_(line), dap.terminate(), dap.disconnect(), dap.restart(), dap.close()
dap.attach(config)       -- e.g. processId
dap.launch(config)
dap.set_exception_breakpoints(filters, exceptionOptions)
dap.set_breakpoint(condition, hit_condition, log_message)   -- cursor-bound
dap.toggle_breakpoint(condition, hit_condition, log_message, replace_old)
dap.clear_breakpoints()
dap.list_breakpoints(openqf)      -- fills + optionally opens the quickfix list
dap.listeners            -- { before = {}, after = {}, on_config = {}, on_session = {} }
dap.defaults.fallback    -- exception_breakpoints, terminal_win_cmd, focus_terminal,
                         -- stepping_granularity, auto_continue_if_many_stopped
dap.providers.configs    -- config-provider registry used by pickers
dap.repl                 -- open(), execute(text, opts, cb), append(), clear(), toggle()
dap.breakpoints          -- see below
dap.ext.vscode           -- load_launchjs(), getconfigs(), json_decode
dap.utils                -- notify, pick_process, pick_file, fmt_error
```

`dap.listeners.even` does not exist in this version. `before`/`after` have an
auto-vivifying `__index`, so `dap.listeners.after.event_stopped["ns"] = fn` works
without creating the table; `on_session` is a plain table.

### Listener signatures

```lua
-- shape sketch: <name> is one of the strings listed below
dap.listeners.after[<name>][key] = fn
-- name is a DAP request:  continue, stackTrace, scopes, variables, evaluate,
--                          setBreakpoints, threads, launch, attach, restart,
--                          disconnect, exceptionInfo, setVariable, setExpression
-- or an event:            event_stopped, event_continued, event_output,
--                          event_exited, event_terminated, event_initialized,
--                          event_breakpoint, event_loadedSource, event_thread,
--                          event_capabilities, event_module, event_progressStart
-- request listeners: fn(session, err, body, request_args, request_seq)
-- event   listeners: fn(session, body)
-- return truthy to be removed after this call
dap.listeners.on_session[key] = function(old_session, new_session) end  -- new == nil on end
dap.listeners.on_config[key] = function(config) end                     -- variable expansion hooks
```

### Synchronous requests

```lua
local s = require("dap").session()
local tid = s.stopped_thread_id
local res
local co = coroutine.create(function() res = { s:request("stackTrace", { threadId = tid }) } end)
coroutine.resume(co)
if vim.wait(5000, function() return res ~= nil end, 10) then
  local err, body = res[1], res[2]   -- err.message on failure; never a Lua error
end
```

Also available: `s:request_with_timeout(cmd, args, ms, cb)`, `s:evaluate(args, cb)`,
`s:update_threads(cb)`, `s:restart_frame()`, `s:source(src, cb)`,
`s:set_exception_breakpoints(...)`, `s:set_breakpoints(bps, on_done)` where
`bps = {[bufnr] = {bp,...}}`.

### Session fields

Instance fields worth reading: `config`, `adapter`, `capabilities`, `threads`
(keyed by thread id; each may hold `frames`, and each frame `scopes`, and each
scope `variables`, all populated by the UI flow), `current_frame`,
`stopped_thread_id`, `initialized`, `closed`, `dirty`, `filetype`, `id`,
`children`, `sign_group`, `ns`, `pid`. Frames have `id`, `name`, `line`,
`column`, `source = { path, name, sourceReference }`, `scopes`.

### Breakpoint store

```lua
local bp = require("dap.breakpoints")
bp.set(opts, bufnr, lnum)     -- opts = { condition, hit_condition, log_message, replace }
bp.toggle(opts, bufnr, lnum)  -- snake_case in; stored camelCase (hitCondition, logMessage)
bp.get(bufexpr)               -- { [bufnr] = { {line, condition, hitCondition, logMessage, state} } }
bp.remove(bufnr, lnum)        -- true if one was there
bp.remove_by_id(id)
bp.set_state(bufnr, state)
bp.update(breakpoint)         -- needs breakpoint.id
bp.clear()                    -- unplace all signs; also AgentDAP.clear_bps() syncs
bp.to_qf_list(bp.get())       -- quickfix item list, for set_quickfix
```

Breakpoints live as *signs* (group `dap_breakpoints`); `bp.get()` reads the sign
placements, so an unverified or cleared breakpoint shows up through signs.
`AgentDAP.bps()` maps sign state to `verified` / `pending` / `unsynced` /
`REJECTED`.

## Companion plugins in this config

```lua
-- shape sketch, not a runnable chunk
local dv = require("dap-view")
dv.open() / dv.close(hide_terminal) / dv.toggle(hide_terminal)
dv.show_view(name) / dv.jump_to_view(name) / dv.add_expr(expr, default_expanded)
dv.hover(expr, enter, opts) / dv.navigate(opts)
dv.virtual_text_enable() / dv.virtual_text_disable() / dv.virtual_text_toggle()
require("dap-view.state")  -- watched_expressions keyed by expression string,
                            -- each { response = { result = ... }, err, children, expanded, updated }
                            -- also last_frames, current_section, win_pos
require("nvim-dap-virtual-text").enable() / .disable() / .toggle() / .is_enabled() / .refresh(session)
require("dap-disasm").step_into() / .step_over() / .step_back() / .refresh() / .set_memref(ref, before, after)
require("dap-breakpoints.api").save_breakpoints({notify="never"}) / .load_breakpoints({notify="never"})
  :toggle_virtual_text() / .go_to_previous() / .go_to_next() / .edit_property({all=true})
require("dap-breakpoints.api")._set_breakpoint({condition=, hitCondition=, logMessage=})  -- cursor-bound, no prompt
require("persistent-breakpoints.api").toggle_breakpoint() / .store_breakpoints()
  :load_breakpoints() / .reload_breakpoints() / .set_conditional_breakpoint() / .set_log_point()
```

`dap-breakpoints` and `persistent-breakpoints` persist to
`~/.local/share/nvim/nvim_checkpoints`. Restoring is governed by two separate
knobs, and setting the wrong one changes nothing: `persistent-breakpoints`'
`load_breakpoints_event = nil` (this config) disables its startup restore, while
`dap-breakpoints`' `auto_load = true` reloads anyway - SKILL.md has the chain and
the remedy. Use `AgentDAP.persist()` to write your own set through.
`save_breakpoints`/`load_breakpoints` take an options table and do not prompt;
`set_breakpoint`, `set_conditional_breakpoint`, `set_hit_condition_breakpoint`,
`set_log_point` all prompt.
