-- Require all other `.lua` files in the same directory

local info = debug.getinfo(1, "S")
local module_directory = string.match(info.source, "^@(.*)/")
local module_filename = string.match(info.source, "/([^/]*)$")

-- Apparently the name of this module is given as an argument when it is
-- required, and apparently we get that argument with three dots.
local module_name = ... or "init.d"

local function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "' .. directory .. '"')
  for filename in pfile:lines() do ---@diagnostic disable-line: need-check-nil
    i = i + 1
    t[i] = filename
  end
  pfile:close() ---@diagnostic disable-line: need-check-nil
  return t
end

local lua_config_files = vim.tbl_filter(function(filename)
  local is_lua_module = string.match(filename, "[.]lua$")
  local is_this_file = filename == module_filename
  return is_lua_module and not is_this_file
end, scandir(module_directory))

for i, filename in ipairs(lua_config_files) do
  local config_module = string.match(filename, "(.+).lua$")
  require(module_name .. "." .. config_module)
end

local vimscript_config_files = vim.tbl_filter(function(filename)
  local is_config = string.match(filename, "[.]vim$")
  local is_this_file = filename == module_filename
  return is_config and not is_this_file
end, scandir(module_directory))

for i, filename in ipairs(vimscript_config_files) do
  vim.cmd("source " .. module_directory .. "/" .. filename)
end
