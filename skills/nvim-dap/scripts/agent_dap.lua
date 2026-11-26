-- agent_dap.lua -- synchronous DAP control surface for agents driving nvim-dap
-- through an RPC bridge (nvim-editor-mcp `nvim_exec_lua`).
--
-- Install once per Neovim session; the table survives in _G across bridge calls:
--   local f = assert(io.open("<SKILL_DIR>/scripts/agent_dap.lua"))
--   assert(load(f:read("a"), "agent_dap"))()
--   return AgentDAP.install()
-- <SKILL_DIR> is this skill's directory as reported by your harness; see the
-- nvim-bridge skill, references/portability.md, for resolution and for the
-- path-free options. Self-contained: it does not call Bridge, so load order
-- never matters and the shared await primitive is duplicated on purpose.
--
-- Every public function returns a plain string. That is deliberate: the bridge
-- JSON-encodes the return value, and a table mixing array and hash parts fails
-- conversion outright ("Cannot convert given Lua table"). Strings always ship.

local dap = require("dap")
local bp = require("dap.breakpoints")

local A = {}
_G.AgentDAP = A

A.out_limit = 200
A.out = {}
A.ev = { stopped = 0, continued = 0, exited = 0, terminated = 0, session = 0, ended = 0 }
A.last_stop = nil
A.last_error = nil
A.installed = false
A.ns = "agent"

local function clip(v, n)
  local s = type(v) == "table" and vim.inspect(v):gsub("%s+", " ") or tostring(v)
  return (#s > (n or 200)) and (s:sub(1, n or 200) .. "...") or s
end

-- Run an async DAP call to completion without leaving the bridge hanging.
-- Session:request yields the current coroutine when no callback is passed and
-- nvim-dap resumes it from vim.schedule; vim.wait pumps the event loop.
local function await(make_call, ms)
  local res
  local co = coroutine.create(function()
    res = { make_call() }
  end)
  coroutine.resume(co)
  if not vim.wait(ms or 4000, function() return res ~= nil end, 10) then
    return nil, "timed out after " .. tostring(ms or 4000) .. "ms"
  end
  local err, body = res[1], res[2]
  if err then return nil, (type(err) == "table" and (err.message or clip(err, 160))) or tostring(err) end
  return body
end

local function session_or_nil()
  return dap.session()
end

function A.install()
  if A.installed then return "AgentDAP already installed" end
  -- Listeners must return nil. Any truthy return self-unregisters the listener
  -- (dap/session.lua call_listener: `if remove then listeners[key] = nil end`).
  -- call_listener iterates with pairs() and does not pcall, so one throwing
  -- listener stops every later listener for that event -- including dap-view's.
  -- Keep our own bodies total functions.
  local function safe(fn)
    return function(...)
      local ok, err = pcall(fn, ...)
      if not ok then A.last_error = clip(err, 200) end
    end
  end
  dap.listeners.after.event_output[A.ns] = safe(function(_, body)
    A.out[#A.out + 1] = string.format("%-9s| %s", tostring(body and body.category), tostring(body and body.output):gsub("%s+$", ""))
    while #A.out > A.out_limit do table.remove(A.out, 1) end
  end)
  dap.listeners.after.event_stopped[A.ns] = safe(function(_, body)
    A.ev.stopped = A.ev.stopped + 1
    A.last_stop = body
  end)
  dap.listeners.after.event_continued[A.ns] = safe(function() A.ev.continued = A.ev.continued + 1 end)
  dap.listeners.after.event_exited[A.ns] = safe(function(_, body)
    A.ev.exited = A.ev.exited + 1
    A.ev.ended = A.ev.ended + 1
    A.exit_code = body and body.exitCode
  end)
  dap.listeners.after.event_terminated[A.ns] = safe(function()
    A.ev.terminated = A.ev.terminated + 1
    A.ev.ended = A.ev.ended + 1
  end)
  dap.listeners.on_session[A.ns] = safe(function(_, new)
    A.ev.session = A.ev.session + 1
    if not new then
      A.ev.ended = A.ev.ended + 1
      A.out[#A.out + 1] = "session   | ended"
    end
  end)
  A.installed = true
  return "AgentDAP installed (namespace: " .. A.ns .. ")"
end

function A.listeners()
  local dap_mod = require("dap")
  local lines = {}
  for _, ev in ipairs({ "event_output", "event_stopped", "event_continued", "event_exited", "event_terminated" }) do
    local names = {}
    for k in pairs(dap_mod.listeners.after[ev] or {}) do names[#names+1] = tostring(k) end
    table.sort(names)
    lines[#lines + 1] = ev .. ": " .. table.concat(names, ", ")
  end
  return table.concat(lines, "\n")
end

function A.uninstall()
  local dap_mod = require("dap")
  for _, ev in ipairs({ "event_output", "event_stopped", "event_continued", "event_exited", "event_terminated" }) do
    if dap_mod.listeners.after[ev] then dap_mod.listeners.after[ev][A.ns] = nil end
  end
  dap_mod.listeners.on_session[A.ns] = nil
  A.installed = false
  return "uninstalled (AgentDAP state kept; call A.install() to resume capture)"
end

--- Blocks until `cond`, or the session we marked against ends, or ms elapses.
--- Comparing against a mark (never absolute counters) matters: a prior session
--- that already exited would otherwise make every later wait return instantly.
local function wait_until(ms, mark, cond)
  local ended = function() return mark ~= nil and A.ev.ended > mark.ended end
  local ok = vim.wait(ms, function() return ended() or cond() end, 20)
  return ok, ended()
end

-- The stopped thread's frames survive an event_continued, so `thread.frames`
-- alone is stale evidence; `current_frame` is only assigned after the
-- stackTrace round-trip inside Session:event_stopped, so it is the settled mark.
local function frame_ready(s)
  return s.stopped_thread_id ~= nil and s.current_frame ~= nil
end

--- Snapshot before an operation, then pass it to A.settled.
function A.mark()
  return { stopped = A.ev.stopped, ended = A.ev.ended }
end

--- Wait for the stop that follows an operation. A timeout here usually means
--- the program kept running (no breakpoint reached), not a broken bridge.
function A.settled(ms, mark)
  ms = ms or 12000
  -- Called without a mark: wait for the stop already in flight to settle.
  mark = mark or { stopped = A.ev.stopped - 1, ended = A.ev.ended }
  local ok, ended = wait_until(ms, mark, function()
    local s = session_or_nil()
    return s ~= nil and A.ev.stopped > mark.stopped and frame_ready(s)
  end)
  if ended then return "program ended (exit=" .. tostring(A.exit_code) .. ")\n" .. A.tail(6) end
  if not ok then return "TIMEOUT after " .. tostring(ms) .. "ms (still running)\n" .. A.state() end
  return "settled: " .. A.where()
end

function A.tail(n)
  local lines = {}
  for i = math.max(1, #A.out - (n or 12) + 1), #A.out do lines[#lines + 1] = clip(A.out[i], 200) end
  if #lines == 0 then return "no output captured" end
  return table.concat(lines, "\n")
end

function A.state()
  local s = session_or_nil()
  local lines = {}
  lines[#lines + 1] = "session: " .. (s and (clip((s.config or {}).name) .. " type=" .. tostring((s.config or {}).type)) or "none")
  if s then
    lines[#lines + 1] = "  adapter=" .. tostring(s.adapter and (s.adapter.id or s.adapter.type) or "?")
      .. " initialized=" .. tostring(s.initialized) .. " closed=" .. tostring(s.closed)
    lines[#lines + 1] = "  stopped_thread=" .. tostring(s.stopped_thread_id) .. " threads=" .. tostring(vim.tbl_count(s.threads or {}))
    lines[#lines + 1] = "  " .. A.where()
    lines[#lines + 1] = "  last_stop: reason=" .. tostring(A.last_stop and A.last_stop.reason)
      .. " allThreads=" .. tostring(A.last_stop and A.last_stop.allThreadsStopped)
      .. " text=" .. clip(A.last_stop and (A.last_stop.text or A.last_stop.description), 120)
    local caps = s.capabilities or {}
    lines[#lines + 1] = "  caps: stepBack=" .. tostring(caps.supportsStepBack)
      .. " restartFrame=" .. tostring(caps.supportsRestartFrame)
      .. " goto=" .. tostring(caps.supportsGoto)
      .. " setVariable=" .. tostring(caps.supportsSetVariable)
      .. " exceptionFilters=" .. tostring(caps.supportsExceptionFilterOptions)
  end
  local e = A.ev
  lines[#lines + 1] = string.format("events: stopped=%d continued=%d exited=%d terminated=%d session=%d",
    e.stopped, e.continued, e.exited, e.terminated, e.session)
  lines[#lines + 1] = "breakpoints: " .. tostring(A.bp_count()) .. " placed, " .. tostring(A.wanted_count()) .. " intended"
  lines[#lines + 1] = "last_error: " .. clip(A.last_error or "none", 200)
  lines[#lines + 1] = "output tail:"
  for i = math.max(1, #A.out - 7), #A.out do lines[#lines + 1] = "  " .. clip(A.out[i], 160) end
  if #A.out == 0 then lines[#lines + 1] = "  (none)" end
  return table.concat(lines, "\n")
end

function A.where()
  local s = session_or_nil()
  if not s then return "no session" end
  local f = s.current_frame
  if not f then return "running (no current frame)" end
  local src = f.source or {}
  local path = src.path or src.name or (src.sourceReference and "sourceReference:" .. src.sourceReference) or "?"
  return string.format("%s @ %s:%d:%d", clip(f.name, 60), path, f.line or -1, f.column or 0)
end

--- Full stack for the stopped thread, preferring the frames nvim-dap already
--- fetched and falling back to a request.
function A.frames(ms)
  local s = session_or_nil()
  if not s then return "no session" end
  local tid = s.stopped_thread_id
  if not tid then return "no stopped thread; use A.threads()" end
  local th = s.threads and s.threads[tid]
  local frames = th and th.frames
  if not frames then
    local body, err = await(function() return s:request("stackTrace", { threadId = tid, startFrame = 0, levels = 60 }) end, ms)
    if not body then return "stackTrace failed: " .. tostring(err) end
    frames = body.stackFrames
  end
  if not frames or #frames == 0 then return "no frames" end
  local lines = { "thread " .. tid .. " (" .. tostring(th and th.name) .. "), " .. #frames .. " frames:" }
  for i, f in ipairs(frames) do
    local mark = (s.current_frame and f.id == s.current_frame.id) and ">" or " "
    local src = f.source or {}
    lines[#lines + 1] = string.format("%s #%d %s  %s:%d", mark, i, clip(f.name, 50),
      (src.path or src.name or "?"):gsub(".*/", ""), f.line or -1)
  end
  return table.concat(lines, "\n")
end

function A.threads()
  local s = session_or_nil()
  if not s then return "no session" end
  local lines = {}
  for id, th in pairs(s.threads or {}) do
    lines[#lines + 1] = string.format("thread %s name=%s stopped=%s frames=%s", tostring(id),
      tostring(th.name), tostring(th.stopped), tostring(th.frames and #th.frames or 0))
  end
  if #lines == 0 then return "no threads known yet" end
  return table.concat(lines, "\n")
end

--- Variables for the current frame. `depth` > 1 expands container references.
function A.locals(depth, ms)
  local s = session_or_nil()
  if not s then return "no session" end
  if not s.current_frame then return "no current frame (still running?)" end
  local f = s.current_frame
  local scopes, err = await(function() return s:request("scopes", { frameId = f.id }) end, ms)
  if not scopes then return "scopes failed: " .. tostring(err) end
  local lines = { "frame " .. clip(f.name, 40) .. " @" .. tostring(f.line) }
  for _, sc in ipairs(scopes.scopes or {}) do
    lines[#lines + 1] = "-- " .. sc.name .. (sc.expensive and " (expensive: fetch on demand)" or "")
    local vars, verr = await(function() return s:request("variables", { variablesReference = sc.variablesReference }) end, ms)
    if not vars then
      lines[#lines + 1] = "   (variables failed: " .. tostring(verr) .. ")"
    else
      for _, v in ipairs(vars.variables or {}) do
        lines[#lines + 1] = string.format("   %s = %s", v.name, clip(v.value, 90))
        if (depth or 1) > 1 and v.variablesReference > 0 then
          local kids = await(function() return s:request("variables", { variablesReference = v.variablesReference }) end, ms)
          for _, k in ipairs(kids and kids.variables or {}) do
            lines[#lines + 1] = string.format("       .%s = %s", k.name, clip(k.value, 70))
          end
        end
      end
    end
  end
  return table.concat(lines, "\n")
end

--- Evaluate in the current frame. context: repl|hover|watch|variables.
function A.eval(expr, context, ms)
  local s = session_or_nil()
  if not s then return "no session" end
  local body, err = await(function()
    return s:request("evaluate", { expression = expr, frameId = (s.current_frame or {}).id, context = context or "repl" })
  end, ms)
  if not body then return "evaluate failed: " .. tostring(err) end
  return expr .. " = " .. clip(body.result, 400)
    .. (body.variablesReference and body.variablesReference > 0 and ("  [ref " .. body.variablesReference .. "]") or "")
end

function A.assign(expr, value, ms)
  local s = session_or_nil()
  if not s then return "no session" end
  if not (s.capabilities or {}).supportsSetVariable then return "adapter does not support setVariable" end
  local f = s.current_frame
  if not f or not f.scopes or not f.scopes[1] then return "no scope handle; call A.locals() first" end
  local body, err = await(function()
    return s:request("setVariable", { variablesReference = f.scopes[1].variablesReference, name = expr, value = value })
  end, ms)
  if not body then return "setVariable failed: " .. tostring(err) end
  return expr .. " := " .. clip(body.result or value, 200)
end

-- ---------------------------------------------------------------- breakpoints

-- dap-breakpoints.nvim runs load_breakpoints() on BufReadPost with auto_load =
-- true, and that path calls persistent-breakpoints reload_breakpoints(), which
-- does breakpoints.clear() and restores only what is saved on disk. Loading the
-- debuggee's source buffer therefore wipes any breakpoint set through the raw
-- nvim-dap API. Keep the intended set here and write it through to the plugin
-- store so a reload restores it instead of dropping it.
A.wanted = {}

local function record(path, line, opts)
  A.wanted[path] = A.wanted[path] or {}
  A.wanted[path][line] = opts or {}
end

function A.persist()
  local ok, err = pcall(function()
    require("dap-breakpoints.api").save_breakpoints({ notify = "never" })
  end)
  return ok and "saved to disk store" or ("persist unavailable: " .. clip(err, 140))
end

function A.bp(path, line, opts)
  if vim.fn.filereadable(path) ~= 1 then return "not readable: " .. path end
  local bufnr = vim.fn.bufadd(path)
  pcall(vim.fn.bufload, bufnr)
  pcall(vim.api.nvim_set_option_value, "buflisted", true, { buf = bufnr })
  bp.set({
    condition = opts and opts.condition,
    hit_condition = opts and opts.hit,
    log_message = opts and opts.log,
    replace = true,
  }, bufnr, line)
  record(path, line, opts)
  A.persist()
  local note = "bp " .. path .. ":" .. line
  if opts and (opts.condition or opts.hit or opts.log) then
    note = note .. " {cond=" .. tostring(opts.condition) .. ", hit=" .. tostring(opts.hit) .. ", log=" .. clip(opts.log, 40) .. "}"
  end
  local s = session_or_nil()
  if s then return note .. "\n" .. A.sync() else return note end
end

function A.ubp(path, line)
  if A.wanted[path] then A.wanted[path][line] = nil end
  local bufnr = vim.fn.bufnr(path)
  if bufnr == -1 then return "buffer not loaded: " .. path end
  if bp.remove(bufnr, line) then
    A.persist()
    local s = session_or_nil()
    if s then return "removed " .. path .. ":" .. line .. "\n" .. A.sync() end
    return "removed " .. path .. ":" .. line
  end
  return "no breakpoint at " .. path .. ":" .. line
end

--- Re-place every intended breakpoint, then persist and sync. Use after a
--- launch or a `load_breakpoints` wiped the set.
function A.apply()
  local n = 0
  for path, byline in pairs(A.wanted) do
    if vim.fn.filereadable(path) == 1 then
      local bufnr = vim.fn.bufadd(path)
      pcall(vim.fn.bufload, bufnr)
      for line, opts in pairs(byline) do
        bp.set({
          condition = opts.condition,
          hit_condition = opts.hit,
          log_message = opts.log,
          replace = true,
        }, bufnr, line)
        n = n + 1
      end
    end
  end
  A.persist()
  local s = session_or_nil()
  if s then return "re-applied " .. n .. " breakpoints\n" .. A.sync() end
  return "re-applied " .. n .. " breakpoints"
end

--- Intended vs actually placed: catches the silent wipe.
function A.verify()
  local placed = {}
  for bufnr, list in pairs(bp.get()) do
    local name = vim.api.nvim_buf_get_name(bufnr)
    for _, b in ipairs(list) do placed[name .. ":" .. b.line] = true end
  end
  local missing, have = {}, 0
  for path, byline in pairs(A.wanted) do
    for line in pairs(byline) do
      if placed[path .. ":" .. line] then have = have + 1 else missing[#missing + 1] = path .. ":" .. line end
    end
  end
  table.sort(missing)
  if #missing == 0 then return "ok: " .. have .. "/" .. (have + #missing) .. " intended breakpoints placed" end
  return "MISSING " .. #missing .. " of " .. (have + #missing) .. ": " .. table.concat(missing, ", ") .. "\n" .. A.apply()
end

--- Push the local breakpoint set to every live session. Without this the
--- adapter keeps running the old set -- nvim-dap only broadcasts from
--- dap.set_breakpoint / dap.toggle_breakpoint, not from dap.breakpoints.set.
function A.sync(ms)
  local s = session_or_nil()
  if not s then return "no session (nothing to sync)" end
  local done = false
  s:set_breakpoints(bp.get(), function() done = true end)
  local ok = vim.wait(ms or 5000, function() return done end, 10)
  return ok and "breakpoints synced" or "sync did not complete in " .. tostring(ms or 5000) .. "ms"
end

function A.bps()
  local all, lines, n = bp.get(), {}, 0
  for bufnr, list in pairs(all) do
    for _, b in ipairs(list) do
      n = n + 1
      local st = b.state
      lines[#lines + 1] = string.format("%s:%d %s%s%s%s",
        (vim.api.nvim_buf_get_name(bufnr):gsub(".*/", "")), b.line,
        st and (st.verified and "verified" or (st.verified == false and "REJECTED" or "pending")) or "unsynced",
        b.condition and (" cond=" .. clip(b.condition, 50)) or "",
        b.hitCondition and (" hit=" .. tostring(b.hitCondition)) or "",
        b.logMessage and (" log=" .. clip(b.logMessage, 50)) or "")
    end
  end
  if n == 0 then return "no breakpoints" end
  return n .. " breakpoints:\n" .. table.concat(lines, "\n")
end

function A.bp_count()
  local n = 0
  for _, list in pairs(bp.get()) do n = n + #list end
  return n
end

function A.wanted_count()
  local n = 0
  for _, byline in pairs(A.wanted) do n = n + vim.tbl_count(byline) end
  return n
end

function A.clear_bps()
  bp.clear()
  A.wanted = {}
  A.persist()
  local s = session_or_nil()
  if s then return "cleared\n" .. A.sync() end
  return "cleared"
end

-- ------------------------------------------------------------------ execution

function A.run(config, ms)
  if type(config) ~= "table" then return "config must be a table (never call dap.continue(): it opens a picker)" end
  if not dap.adapters[config.type] then
    A.last_error = "unknown adapter type=" .. tostring(config.type)
    return "ERROR: " .. A.last_error .. "\nknown adapters: " .. table.concat(A.adapters(), ", ")
  end
  local mark = A.mark()
  A.apply()
  local okc, errc = pcall(dap.run, config)
  if not okc then return "run failed: " .. clip(errc, 300) end
  local waited = A.settled(ms or 20000, mark)
  if waited:find("^TIMEOUT") then return waited .. "\n" .. A.state() end
  return "launched\n" .. A.verify() .. "\n" .. waited
end

function A.cont(ms)
  local s = session_or_nil()
  if not s then return "no session" end
  if not s.stopped_thread_id then
    dap.pause()
    return "was already running; issued pause instead"
  end
  local mark = A.mark()
  dap.continue()
  return A.settled(ms or 30000, mark)
end

function A.step(kind, ms)
  local s = session_or_nil()
  if not s then return "no session" end
  if not s.stopped_thread_id then return "not stopped; cannot step" end
  local fn = ({ over = dap.step_over, into = dap.step_into, out = dap.step_out, back = dap.step_back })[kind or "over"]
  if not fn then return "kind must be over|into|out|back" end
  if kind == "back" and not (s.capabilities or {}).supportsStepBack then
    return "adapter does not support reverse stepping"
  end
  local mark = A.mark()
  fn()
  return A.settled(ms or 15000, mark)
end

function A.pause()
  if not session_or_nil() then return "no session" end
  dap.pause()
  return "pause requested"
end

function A.up(n)
  if not session_or_nil() then return "no session" end
  for _ = 1, (n or 1) do dap.up() end
  return A.where()
end

function A.down(n)
  if not session_or_nil() then return "no session" end
  for _ = 1, (n or 1) do dap.down() end
  return A.where()
end

--- Restart the current frame (rewind a loop iteration / re-run a function).
function A.rewind(ms)
  local s = session_or_nil()
  if not s then return "no session" end
  if not (s.capabilities or {}).supportsRestartFrame then return "adapter does not support restartFrame" end
  if not s.current_frame then return "no current frame" end
  local mark = A.mark()
  s:restart_frame()
  return A.settled(ms or 10000, mark)
end

function A.goto_line(line)
  local s = session_or_nil()
  if not s then return "no session" end
  if not (s.capabilities or {}).supportsGoto then return "adapter does not support goto" end
  local mark = A.mark()
  dap.goto_(line)
  return A.settled(ms or 10000, mark)
end

function A.exception_breaks(filters, ms)
  local s = session_or_nil()
  if not s then return "no session" end
  local mark = A.mark()
  dap.set_exception_breakpoints(filters or { "all" })
  return "exception breakpoints: " .. tostring(filters and table.concat(filters, ",") or "all") .. "\n" .. A.settled(ms or 20000, mark)
end

--- End the session. Leaves the DAP UI alone: auto_toggle already closes the
--- pane when the session ends, and the human may have opened it themselves.
function A.terminate(ms)
  local s = session_or_nil()
  if not s then return "no session" end
  dap.terminate()
  vim.wait(ms or 8000, function() return vim.tbl_count(dap.sessions()) == 0 end, 20)
  return "terminated; sessions left=" .. tostring(vim.tbl_count(dap.sessions())) .. "\n" .. A.tail(8)
end

--- Close the DAP UI panes when a finished run leaves them in the way.
function A.close_ui(hide_terminal)
  local ok, err = pcall(function() require("dap-view").close(hide_terminal and true or false) end)
  return ok and "dap-view closed" or ("close failed: " .. clip(err, 160))
end

-- ----------------------------------------------------------------- inspection

--- Make the human see the current frame: DapStopped sign + window jump.
--- Guarded: dap.focus_frame() opens a threads picker float when there is no
--- current frame, which would block the bridge waiting on the human.
function A.show_frame()
  local s = session_or_nil()
  if not s then return "no session" end
  if not s.current_frame then return "no current frame yet" end
  dap.focus_frame()
  return "jumped to " .. A.where()
end

function A.watch(expr)
  local dv = require("dap-view")
  dv.add_expr(expr)
  return "watch added: " .. expr .. " (visible in the Watches section)"
end

function A.watches()
  local lines = {}
  for expr, w in pairs(require("dap-view.state").watched_expressions) do
    lines[#lines + 1] = expr .. " => " .. (w.err and ("error: " .. clip(w.err.message, 120))
      or clip(w.response and w.response.result, 120) or "(pending)")
  end
  if #lines == 0 then return "no watches" end
  table.sort(lines)
  return table.concat(lines, "\n")
end

--- Hover float for the human, showing an expression's value.
function A.hover(expr)
  local ok, err = pcall(function() require("dap-view").hover(expr, false, {}) end)
  return ok and ("hover shown for " .. expr) or ("hover failed: " .. clip(err, 160))
end

function A.view(name)
  local ok, err = pcall(function() require("dap-view").show_view(name) end)
  if not ok then return "show_view failed: " .. clip(err, 160) end
  return "dap-view section: " .. name
end

--- Text the human currently sees in the DAP UI pane, for grounding a report.
function A.ui_text(limit)
  local bufnr = -1
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[b].filetype == "dap-view" then bufnr = b break end
  end
  if bufnr == -1 then return "no dap-view buffer (is nvim-dap-view open?)" end
  local name = vim.api.nvim_buf_get_name(bufnr):gsub(".*/", "")
  local lines, n = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), 0
  local shown = { "[" .. name .. "]" }
  for _, l in ipairs(lines) do
    if l:match("%S") then
      n = n + 1
      if n <= (limit or 60) then shown[#shown + 1] = clip(l, 120) end
    end
  end
  return table.concat(shown, "\n")
end

function A.adapters()
  local names = {}
  for k in pairs(dap.adapters) do names[#names + 1] = tostring(k) end
  table.sort(names)
  return names
end

function A.preflight(ftype)
  local lines = {}
  local a = dap.adapters[ftype]
  if not a then
    lines[#lines + 1] = "adapter '" .. tostring(ftype) .. "' NOT registered. Registered: " .. table.concat(A.adapters(), ", ")
  elseif type(a) == "function" then
    lines[#lines + 1] = "adapter '" .. ftype .. "' is a lazy factory (resolved on first use)"
  else
    local exe = a.command or (a.args and a.args[1])
    lines[#lines + 1] = "adapter '" .. ftype .. "': " .. tostring(a.type) .. " command=" .. tostring(exe)
      .. (exe and vim.fn.executable(exe) == 1 and " [found]" or exe and " [NOT ON PATH]" or "")
  end
  local cfgs = dap.configurations[ftype] or {}
  if #cfgs == 0 then
    lines[#lines + 1] = "no preset configurations for type '" .. ftype .. "'"
  else
    for _, c in ipairs(cfgs) do lines[#lines + 1] = "config: " .. tostring(c.name) end
  end
  return table.concat(lines, "\n")
end

--- Source positions in the loaded file that can actually take a breakpoint.
function A.probe(path, lines_to_try, ms)
  local bufnr = vim.fn.bufnr(path)
  if bufnr == -1 then bufnr = vim.fn.bufadd(path); pcall(vim.fn.bufload, bufnr) end
  if bufnr == -1 then return "cannot open " .. path end
  local ft = vim.bo[bufnr].filetype
  local before = A.bp_count()
  for _, l in ipairs(lines_to_try or {}) do bp.set({ replace = true }, bufnr, l) end
  A.last_probe = { path = path, filetype = ft, added = A.bp_count() - before, lines = lines_to_try or {} }
  return "probe staged " .. tostring(A.bp_count() - before) .. " breakpoints in " .. path .. " (ft=" .. tostring(ft) .. "); call A.sync() then A.bps() to read verification"
end

return "AgentDAP loaded (call AgentDAP.install())"
