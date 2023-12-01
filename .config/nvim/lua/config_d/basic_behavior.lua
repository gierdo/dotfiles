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

-- Copy-Paste from X-Buffer
vim.opt.clipboard = "unnamedplus"

-- Use vertical splits for diffs per default
vim.opt.diffopt = vim.opt.diffopt + "vertical"


vim.opt.ts = 2
vim.opt.sts = 2
vim.opt.sw = 2
vim.opt.expandtab = true

-- Reorder tabs on window resize
vim.cmd("autocmd VimResized * wincmd =")

vim.cmd("let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'")
