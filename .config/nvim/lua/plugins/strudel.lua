return {
  {
    "gruvw/strudel.nvim",
    -- node 22: avoids yargs ESM/CJS breakage on node 26+
    build = table.concat({
      [[printf '[tools]\nnode = "22"\n' > .mise.toml]],
      "mise trust",
      "mise install",
      "mise exec -- npm ci",
      [[sed -i 's|local cmd = "node "|local cmd = "mise exec -C " .. plugin_root .. " -- node "|' lua/strudel/init.lua]],
      "true",
    }, " && "),
    config = function()
      require("strudel").setup()
    end,
  },
}
