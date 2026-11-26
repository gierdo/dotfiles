# Keeping the session human-visible and interactive

Verified on this config. nvim-dap with `nvim-dap-view` (`auto_toggle = true`,
`windows.position = "below"`, `terminal.position = "left"`, `follow_tab = true`,
its own `switchbuf = "usetab"`, winbar sections `watches, scopes, exceptions,
breakpoints, threads, repl, sessions`, `default_section = "breakpoints"`),
`nvim-dap-virtual-text` (on), `dap-breakpoints.nvim`, `nvim-dap-disasm`,
`persistent-breakpoints.nvim`, `telescope-dap.nvim`, and `which-key` under
`<leader>d`.

Read those values from `require("dap-view.setup").config` -
`require("dap-view.config").config` holds the *defaults schema*, so it reports
`auto_toggle = false` and `switchbuf = "usetab,uselast"` even when the user set
them otherwise.

## What happens by itself when a breakpoint hits

Confirmed by observation, no agent action required:

- A `dap-view` window opens below (~19 rows, buffer `main`, `filetype = dap-view`).
- The window you were in **switches to the stopped source file at the stopped
  line**. Two different options are both named `switchbuf`; the one that decides
  this jump is nvim-dap's, resolved at `dap/session.lua:605` as
  `defaults(session).switchbuf or vim.o.switchbuf or 'uselast'`. Here
  `dap.defaults.fallback.switchbuf` is nil, so nvim's global default `uselast`
  applies: `jump_to_frame` reuses the current window if it holds a source buffer,
  otherwise the alternate window. nvim-dap-view's `switchbuf = "usetab"` is a
  separate knob used only when the *human picks an entry in the DAP pane*
  (breakpoint, watch, stack frame). Your previous buffer stays listed; nothing is
  closed, and no window is destroyed.
- A `DapStopped` sign is placed in group `dap-stopped`, breakpoint signs in
  `dap_breakpoints`.
- Virtual text renders variable values inline on the stopped line's scope.
- `<10` and `<11`-style notification floats may appear from noice; they close on
  their own.

So "make it visible to the human" is mostly *do not fight it*: do not re-open
windows the plugin manages, and do not repurpose the window the debugger jumped.

## Reading what the human sees

```lua
return AgentDAP.ui_text(40)      -- text of the dap-view pane, section by section
     .. "\n" .. Bridge.ui_inventory()
```

`require("dap-view.state").current_section` tells you which section is focused,
so you can say "look at the Scopes tab" accurately. `Bridge.ui_inventory()`
labels float windows, which matters here: noice pops a float during DAP runs.

## Directing attention

```lua
AgentDAP.show_frame()   -- dap.focus_frame(): sign + jump, guarded against the picker path
AgentDAP.view("watches")
AgentDAP.view("threads")
AgentDAP.watch("state.count")   -- appears in their Watches pane; read back with AgentDAP.watches()
AgentDAP.hover("some_var")       -- hover float for the human
AgentDAP.close_ui(false)         -- only when the run is over and panes are in the way
```

Watches are the friendliest shared surface: you add an expression, they see it
update as you step, and `AgentDAP.watches()` reads the same values back.

Via MCP: `notify` for short status (`"stopped at handler.py:88, stepping"`),
`open_file(path, line)` to put a caller frame in front of them, `get_diagnostics`
to cross-check LSP errors against what the debugger says, `set_quickfix` for a
clickable list of sites.

## Handing control back

The human has working keymaps, resolved live from the running editor (leader is
`,`): `,dc` continue or start, `,dp` pause, `,dr` run to cursor, `,dre` restart,
`,dfd`/`,dfu` frame down/up, `,dd` debug command list, `,dv` variables, `,dbt`
toggle breakpoint, `,dbs` set breakpoint, `,dbc` conditional, `,dbh` hit
condition, `,dbe`/`,dbE` edit properties, `,dbv` virtual text, `,dbC` clear all,
`,dbL`/`,dbS` load/save. DAP-pane winbar controls cover step in/over/back.

Collision in this config worth knowing: `debugging.lua` binds `<leader>dbl` to
telescope's *list breakpoints* and `dap-breakpoints.nvim` binds the same key to
*set log point*; telescope wins. So `<leader>dbl` lists breakpoints, it is not a
log point. Send the human the keys you have actually resolved, not the ones you
expect.

So treat the session as jointly owned: announce the phase before acting
(`notify("driving: stepping 4 times through loop")`) and report `state()` after a
burst of stepping. To pause, say so and leave the session as it is - the human
can take over with `<leader>dc` and you do nothing. On resume, do not assume your
last position: read `state()` and re-derive if `events stopped` moved or the
frame differs. Ask before terminating, they may still be reading values.

A good rhythm: set breakpoints, launch, drive to the interesting frame, then hand
over - `notify("at parser.py:212, token is wrong - continue with <leader>dc")`.

## Restoring the layout

`Bridge.layout_save()` before the session, `Bridge.layout_restore()` after
`AgentDAP.terminate()` - both in `nvim-bridge`. Note that `layout_save` skips
floats, so the notification windows a DAP run opens are not what you restore.

DAP leaves one extra thing behind, so clean that specifically:

```lua
for _, b in ipairs(vim.api.nvim_list_bufs()) do
  if vim.bo[b].filetype == "dap-repl" then pcall(vim.api.nvim_buf_delete, b, { force = true }) end
end
return Bridge.assess()
```

Terminating a session closes the dap-view window via `auto_toggle`, but the
window that jumped to the debuggee still shows that file, and a `[dap-repl-N]`
buffer can linger - as does any library source pulled in by stepping with
`justMyCode = false` (`runpy.py` showed up in testing). Say what you restored,
and note anything you deliberately left (for example a breakpoint they asked you
to keep).
