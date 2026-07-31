return {
  {
    "gruvw/strudel.nvim",
    -- node 22: avoids yargs ESM/CJS breakage on node 26+
    build = table.concat({
      [[printf '[tools]\nnode = "22"\n' > .mise.toml]],
      "mise trust",
      "mise install",
      "mise exec -- npm ci",
      [[mkdir -p .bin]],
      [[printf '#!/bin/sh\nexec mise exec -C "%s" -- node "$@"\n' "$(pwd)" > .bin/node]],
      [[chmod +x .bin/node]],
    }, " && "),
    config = function()
      local plugin_root = vim.fn.stdpath("data") .. "/lazy/strudel.nvim"
      vim.env.PATH = plugin_root .. "/.bin:" .. vim.env.PATH
      require("strudel").setup()
    end,
  },
}
