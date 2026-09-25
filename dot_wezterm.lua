local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.enable_wayland = true
config.exit_behavior = "Close"
config.enable_tab_bar = false

config.default_prog = { "tmux" }

config.color_scheme = "Solarized Dark - Patched"

config.font = wezterm.font_with_fallback({
  "UbuntuMono NerdFont",
  "JetBrains Mono",
})

config.font_size = 13.0
config.adjust_window_size_when_changing_font_size = false
config.warn_about_missing_glyphs = false
config.mux_enable_ssh_agent = false

return config
