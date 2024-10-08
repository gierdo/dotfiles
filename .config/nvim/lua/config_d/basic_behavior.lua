vim.opt.shell = "sh"
vim.opt.syntax = "on"
vim.opt.wrap = true
vim.opt.number = true
vim.opt.cc = "80"
vim.opt.encoding = "utf-8"
vim.opt.mouse = "a"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.wildmenu = true
vim.opt.splitright = true

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- highlight search
vim.opt.hls = true
-- " incremental search (while typing)
vim.opt.is = true

vim.opt.autoread = true
vim.opt.exrc = true
vim.opt.secure = true

-- Remap leader for german keyboard layout
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Copy-Paste from X-Buffer
vim.opt.clipboard = "unnamedplus"

-- Use vertical splits for diffs per default
vim.opt.diffopt = vim.opt.diffopt + "vertical"

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  command = "wincmd J",
  desc = "Open quickfix window in full width at the bottom",
})

vim.opt.ts = 2
vim.opt.sts = 2
vim.opt.sw = 2
vim.opt.expandtab = true

-- Reorder tabs on window resize
vim.api.nvim_create_autocmd("VimResized", {
  pattern = "*",
  command = "wincmd =",
})

vim.cmd("let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'")
vim.cmd.set("wildignore+=*.o,*.obj,**/.git/*,**/.svn/*,**/node_modules/**,node_modules/**,.git/*,svn/*,.ctags")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  command = "setlocal spell spelllang=en_gb,de_de",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  command = "setlocal spell spelllang=en_gb,de_de",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "CMakeLists.txt", command = "set filetype=cmake" })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.gradle", command = "set filetype=groovy" })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.g", command = "set filetype=antlr3" })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.g4", command = "set filetype=antlr4" })
