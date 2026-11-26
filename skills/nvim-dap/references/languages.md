# Languages, adapters, and launch configs in this Neovim

Everything below was read out of the live editor, not assumed. `AgentDAP.preflight(ftype)`
re-checks it, and adapters change when mason installs or a `.vscode/launch.json`
appears in the project - run preflight instead of trusting this list.

## Registered

Adapters (`dap.adapters`): `cppdbg`, `python`, `kotlin` as tables, and `go` as a
**lazy function** (nvim-dap-go resolves it on first use, so `vim.tbl_count` or a
truthiness check is not proof delve is usable - `preflight` says "lazy factory").

Presets (`dap.configurations`, keyed by filetype):

| filetype | configurations |
|---|---|
| `python` | `Python: Launch file`, `Python: Launch file with arguments` |
| `go` | `Debug`, `Debug (Arguments)`, `Debug (Arguments & Build Flags)`, `Debug Package`, `Attach`, `Debug test`, `Debug test (go.mod)` |
| `c`, `cpp`, `rust`, `swift`, `asm` | `Launch file`, `Launch file (args)`, `Attach to gdbserver :1234`, `Attach to gdbserver (port)` (all `cppdbg`) |
| `kotlin` | `launch - kotlin` |

`ensure_installed` in mason-nvim-dap also lists `javadbg`, `netcoredbg`,
`node-debug2-adapter`, but **no adapters or configurations were registered for
them**. Do not build a JS or Java flow on the assumption they exist; check
`AgentDAP.adapters()` and, if missing, either ask the human to install or
register the adapter yourself in the bridge call.

## Config gotchas that hang or misfire

- Any config field may be a **function**, and nvim-dap calls it at launch
  (`eval_option`, `dap.lua:327-352`). That is how `Python: Launch file with
  arguments` and go's `Debug (Arguments)` get their arguments: `vim.fn.input(...)`.
  Reuse a preset only after checking none of its fields prompt.
- `${command:pickProcess}` and `${command:pickFile}` are the two placeholders that
  run an interactive picker (`dap.lua:354-357`). Never pass them.
- `${file}` and friends expand against the **current buffer** (`vim.fn.expand("%:p")`),
  not the file you are thinking of, unless you set `program` to an absolute path
  yourself. Prefer absolute paths.
- Supported placeholders: `${file}`, `${fileBasename}`, `${fileBasenameNoExtension}`,
  `${fileDirname}`, `${fileExtname}`, `${relativeFile}`, `${relativeFileDirname}`,
  `${fileDirnameBasename}`, `${workspaceFolder}`, `${workspaceFolderBasename}`,
  `${env:NAME}`.

## Reusing a preset safely

```lua
local dap = require("dap")
local ftype = "python"                       -- the value you passed to preflight
local target
for _, c in ipairs(dap.configurations[ftype] or {}) do
  if c.name == "Python: Launch file" then target = vim.deepcopy(c) end
end
if not target then return "preset gone; list them: " .. AgentDAP.preflight(ftype) end
target.program = "/absolute/path/to/script.py"   -- overwrite it, do not rely on ${file}
return AgentDAP.run(target, 25000)
```

`.vscode/launch.json` is already loaded into `dap.configurations` by this config
(`dap.ext.vscode.getconfigs()` with a JSON5 decoder), so project-specific launch
entries show up there too - check before inventing one.

## Python (debugpy)

```lua
-- script
return AgentDAP.run({
  type = "python", request = "launch", name = "agent",
  program = "/abs/path/script.py",
  args = { "--verbose", "input.csv" },
  cwd = "/abs/path",
  env = { PYTHONUNBUFFERED = "1" },
  console = "internalConsole",   -- output lands in event_output: agent and human both see it
  justMyCode = false,            -- step into library frames
}, 25000)

-- module
{ type = "python", request = "launch", module = "pytest", args = { "tests/test_x.py", "-x" } }

-- attach to a process you started with bash
{ type = "python", request = "attach", processId = "12345", justMyCode = false }
```

`console = "integratedTerminal"` gives real stdin and a visible terminal, but
output then goes to a terminal buffer, not to `event_output`; `AgentDAP.tail()`
will look empty. Say so if you switch.

## Go (delve via nvim-dap-go)

```lua
return AgentDAP.run({
  type = "go", request = "launch", name = "Debug test",
  program = "/abs/path/pkg", mode = "test",
  programArgs = { "-test.run", "TestThing" },
}, 40000)   -- first build under delve is slow; give it room
```

`terminal.hide = { "go" }` in this config means no DAP terminal pane for Go runs,
so program output arrives only through `event_output` - rely on `AgentDAP.tail()`.

## C / C++ / Rust (cppdbg via OpenDebugAD7)

```lua
return AgentDAP.run({
  type = "cppdbg", request = "launch", name = "agent",
  program = "/abs/path/build/app",
  args = {}, cwd = "/abs/path/build",
  MIMode = "gdb", miDebuggerPath = "gdb",
  setupCommands = {
    { description = "Enable pretty-printing", text = "-enable-pretty-printing", ignoreFailures = true },
  },
}, 30000)
```

Attach to gdbserver: `{ type = "cppdbg", request = "attach", processId = "...", MIMode = "gdb" }`
or the `Attach to gdbserver (port)` preset. Rust needs the binary, not the source:
point `program` at the built executable, and `AgentDAP.probe()` helps find lines
the adapter will verify.

## Log points instead of print-debugging

When the human would rather not stop, a log point keeps the run going and still
reaches them through the DAP pane and `event_output`:

```lua
AgentDAP.bp("/abs/path/handler.py", 88, { log = "token={token.value} at {time}" })
```

For a noisy loop, gate it: `{ hit = "3" }` or `{ condition = "attempt > 5" }`.
Log points still require the adapter to verify the breakpoint, so check
`AgentDAP.bps()` reports `verified`.

## Exceptions

```lua
AgentDAP.exception_breaks({ "raised" })   -- or { "uncaught" }, { "all" }
```

Adapter support varies: debugpy honours these filters, cppdbg needs
`exception_breakpoints` style config. If nothing stops, fall back to
`{ "uncaught" }` and check `capabilities.exceptionFilterOptions` in `state()`.
