local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Wayland false is required to launch in Hyprland 
config.enable_wayland = false
-- config.font = wezterm.font("JetBrains Mono")
-- config.font_size = 10
-- 
-- config.enable_tab_bar = false
-- config.window_decorations = "RESIZE"
-- 
-- 
-- 
-- color_scheme = "tokyonight",
-- automatically_reload_config = true,


return config
