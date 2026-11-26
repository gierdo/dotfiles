# Bridge troubleshooting

Symptom -> cause -> fix -> how to confirm, from real failures. The recovery
ladder at the bottom is the order to try things in.

## Errors returned by the bridge

### `EOF` (and then every later call fails too)

The nvim-side RPC handler is wedged - typically after a Lua error left its async
state inconsistent. Nothing you send afterwards is answered.

Fix: `detach_nvim`, then `attach_nvim(socket=...)` on the same socket. That
recovers it every time observed. Confirm with `nvim_exec_lua` returning `1+1`,
then `Bridge.env()` to see what survived: plugin state, sessions, and your
`_G` tables all persist across a re-attach, so you do not have to start over -
but any `Bridge.errors` or captured output belongs to the previous handler and
may be stale.

### `Cannot convert given Lua table`

Your return value has both array and hash parts, which has no unambiguous JSON
form. Fix: return one shape (`table.concat` of lines, or a pure hash), or
`Bridge.text(value)`, which flattens anything. Related: array holes become
`null` and `vim.NIL` is not the same as absent, so a `{a, nil, b}` can pass
conversion and still surprise the reader.

### `bad argument #1 to 'pairs' (table expected, got nil)`

You indexed a registry that has no entry yet. Several plugin dispatch tables
create sub-tables lazily via `__index` and some do not - `pairs(x.missing)`
throws. Fix: probe before iterating, and remember namespaces are not
symmetrical: a plugin can expose `before`/`after`/`on_config`/`on_session` and no
`even`, so guessing a name from convention gives you `nil`.

### `E158: Invalid buffer name` and other `v:null` errors

Lua `nil` passed to `vim.fn.*` arrives as `v:null`, which many legacy functions
reject instead of treating as "omitted". Fix: pass explicit values, or branch in
Lua. `vim.fn.sign_getplaced(nil, {...})` is the example that bit here.

### `This event loop is already running`

Something tried to run a nested libuv loop inside the RPC handler (plenary
`Async`, or `loop:run()` wrappers). Observed once while requiring a telescope
extension inside a bridge call; the exact trigger was not pinned down, so treat
it as: do not start nested event loops from the handler, and use
`Bridge.await` / `Bridge.cb` for async instead, which only need `vim.wait`. If it
repeats, detach/attach and split the work into two calls.

### Call hangs until the human does something

You triggered a picker, `vim.ui.select`, `vim.ui.input`, or `input()`. The
handler is now waiting on a UI response, and your MCP call has probably timed out
on the client side while the editor is still modal.

Fix: the human has to dismiss it (`<Esc>` / `<C-c>`) - you cannot cancel it over
the same blocked channel, because RPC requests queue behind it. After that,
detach/attach, run `Bridge.assess()`, and check for windows or buffers the
abandoned picker left behind. This state is the entire reason Rule 3 exists.

## Wrong or missing answers

### `TIMEOUT` from `await`/`cb`, but no error anywhere

The resume was never scheduled, or it resumed the wrong coroutine. Classic form:

```lua
vim.defer_fn(function()
  coroutine.resume(coroutine.running(), v)   -- main thread: running() is false
end, 50)
```

Capture the coroutine *inside* it and resume that handle:

```lua
local co = coroutine.running()
vim.defer_fn(function() coroutine.resume(co, v) end, 50)
```

nvim-dap does this with `coresume(co)` - it takes the handle before yielding. If
the shape is right and it still times out, the operation is genuinely slow
(builds, first-run adapters, LSP startup): raise the timeout deliberately rather
than retrying, and say which you did.

### Output, or UI updates, quietly stop after your code ran

Listener/event dispatchers iterate with `pairs()` and do not `pcall`, so a
throwing listener aborts every later listener for that event - including the
plugin's own. Symptom: no errors anywhere, but the pane stopped refreshing, or
captured output went empty.

Fix: register with `Bridge.safe(fn, "label")`, then read `Bridge.errors_report()`.
Look for leftovers under other namespaces (`Bridge.env()` lists your globals;
enumerate the plugin's listener registry to see who is registered). Stale
listeners are the worst version: a closure over a deleted `_G` table throws on
every event for the rest of the editor's life.

### A value you set is gone later

Another plugin owns that state and reloads it from disk. In this editor,
`dap-breakpoints.nvim` has `auto_load = true`, so `BufReadPost` reloads the
persisted set and clears what you set through the raw API - which fires exactly
when a debuggee's source file is loaded.

General fix: before assuming corruption, find who else touches the state
(`create_autocmd` and listener registrations in the plugin's `init.lua`/`setup`),
and write through the owning plugin's persist path instead of around it.

### A config value reads back as the opposite of what the user set

You read the defaults schema, not the merged config. Verified example:
`require("dap-view.config").config` reports `auto_toggle = false` and
`switchbuf = "usetab,uselast"` while the user configured `true`/`"usetab"`,
which live in `require("dap-view.setup").config`. Convention: the module named
after setup or options, not the one named `config`, holds the effective values.
When a documented behavior contradicts what you read, read the second module
before concluding the user's config is wrong.

### Window or buffer counts do not match what you saw earlier

Floats. Notification popups (noice), hover windows, and even statusline helpers
(incline's window is a float here) appear and vanish between calls.
`Bridge.ui_inventory()` labels them and `Bridge.layout_save()` ignores them, so
the snapshot you restore is the real layout. Take the snapshot before your first
mutating call, not after something already popped a window.

### Buffers left behind after a run

Libraries and UIs create real buffers: `[dap-repl-N]`, `dap-view` panes, and any
source file pulled in by stepping into dependencies (`runpy.py` showed up here).
`Bridge.buf_dump` and cleanup loops by `filetype`/name handle it, and
`Bridge.assess()` names what is still dirty or extra.

### Your file edit did not take effect in the editor

The buffer in Neovim is not the file on disk, or the human has unsaved edits. The
Pi extension runs `:wall` and protects dirty buffers for you, but when driving
state directly: check `vim.bo[buf].modified` before overwriting, and prefer
editing through the editor (`nvim_buf_set_text` then `:wall`) when the human must
see the change land. Never write a buffer the human is mid-edit in without
saying so.

### Everything looks right but it is the wrong editor

`attach_nvim` picked an instance in the same workspace but a different project.
`Bridge.env()` shows `cwd`, `pid`, and the current buffer immediately - compare
against what the human described before doing anything that writes.

## Recovery ladder

1. Read the error text literally; it is usually precise (`EOF` and `E158` are not
   vague).
2. `return 1+1` - is the channel alive at all?
3. `return Bridge.env()` - did your globals, sessions, and buffers survive?
4. `detach_nvim` + `attach_nvim` - clears handler wedges.
5. Ask the human to dismiss any modal, then re-assess.
6. `return Bridge.assess()` and `Bridge.ui_inventory()` - find what you left.
7. Clean up, report what you changed and what you could not restore.

## What to report

After bridge work, say: which instance you attached to, what you changed in the
editor (windows, buffers, breakpoints, config), what you restored and what you
deliberately left, and any state you could not verify. The human's editor is the
artifact here, not just the files.
