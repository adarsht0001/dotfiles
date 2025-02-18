local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 10

config.enable_tab_bar = false
config.window_decorations = "RESIZE"

config.window_background_opacity = 0.60

-- Wayland false is required to launch in Hyprland 
config.enable_wayland = false

return config
