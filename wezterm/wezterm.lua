local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_domain = "WSL:Ubuntu"

config.color_scheme = "Afterglow"
config.window_background_opacity = 0.95
config.audible_bell = "Disabled"
config.automatically_reload_config = true
config.enable_tab_bar = false
config.window_decorations = "RESIZE"

config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.font_size = 14

config.keys = {
	{
		key = "r",
		mods = "CMD|SHIFT",
		action = wezterm.action.ReloadConfiguration,
	},
}

return config
