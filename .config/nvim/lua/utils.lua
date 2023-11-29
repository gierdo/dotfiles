local exports = {}


local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end

function exports.load_local_vimscript(script_name)
	local module_directory = script_path()
	vim.cmd('source ' .. module_directory .. script_name)
end

return exports
