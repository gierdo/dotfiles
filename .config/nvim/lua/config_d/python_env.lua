-- Python bindings break in virtual environments with pyenv etc.
--
-- With path resolution of the python executable, pynvim is not installed in
-- the active environment anymore if a virtual env is active.
-- Solution: Create and use a dedicated venv for nvim with pyenv

local function directory_exists(name)
  if type(name) ~= "string" then
    return false
  end
  return os.rename(name, name) and true or false
end

local pyenv_root = os.getenv("PYENV_ROOT")
local nvim_virtualenv_root = pyenv_root .. "/versions/nvim"

-- Set up default virtualenv for nvim
if not directory_exists(nvim_virtualenv_root) then
  os.execute([[
  pyenv virtualenv --force nvim
  PYENV_VERSION=nvim pip install pynvim
  ]])
end

local pythonpath = nvim_virtualenv_root .. "/bin/python"

vim.g.python3_host_prog = pythonpath
vim.g.python_host_prog = pythonpath
