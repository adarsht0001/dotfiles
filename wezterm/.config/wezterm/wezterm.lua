local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Wayland false is required to launch in Hyprland
config.enable_wayland = false

config.font = wezterm.font("JetBrains Mono")
config.font_size = 12
config.enable_tab_bar = false

config.window_padding = {
	bottom = 0,
	right = 0,
	left = 0,
	top = 5
}

config.window_background_opacity = 0.60
config.macos_window_background_blur = 400

config.window_close_confirmation = "NeverPrompt"
return config
