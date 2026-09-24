vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  command = "setlocal spell spelllang=en_gb,de_de",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  command = "setlocal spell spelllang=en_gb,de_de",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  command = "let g:java_ignore_markdown = 1",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "org",
  command = "setlocal spell spelllang=en_gb,de_de",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "CMakeLists.txt", command = "set filetype=cmake" })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.gradle", command = "set filetype=groovy" })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.g", command = "set filetype=antlr3" })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.g4", command = "set filetype=antlr4" })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, { pattern = "*.j2", command = "set filetype=jinja" })
