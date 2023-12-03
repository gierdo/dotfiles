-- Python bindings break in virtual environments with pyenv etc.
--
-- With path resolution of the python executable, pynvim is not installed in
-- the active environment anymore if a virtual env is active. Solution: Set the
-- "global" python executable as python host prog

local home = os.getenv("HOME")
local pythonpath = home .. "/.dotfiles/pyenv/shims/python"

vim.g.python3_host_prog = pythonpath
vim.g.python_host_prog = pythonpath
