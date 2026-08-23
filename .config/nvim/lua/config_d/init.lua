-- Require all other `.lua` and `.vim` files in the same directory

local info = debug.getinfo(1, "S")
local module_directory = string.match(info.source, "^@(.*)/")
local module_filename = string.match(info.source, "/([^/]*)$")
local module_name = ... or "config_d"

local files = {}
for name, type in vim.fs.dir(module_directory) do
  if type == "file" and name ~= module_filename then
    table.insert(files, name)
  end
end
table.sort(files)

for _, name in ipairs(files) do
  local lua_module = string.match(name, "(.+)%.lua$")
  if lua_module then
    require(module_name .. "." .. lua_module)
  elseif string.match(name, "%.vim$") then
    vim.cmd("source " .. module_directory .. "/" .. name)
  end
end

