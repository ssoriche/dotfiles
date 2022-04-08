local wezterm = require("wezterm")

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

wezterm.on("toggle-leader", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.leader then
		overrides.leader = { key = "b", mods = "CTRL" }
	else
		overrides.leader = nil
		overrides.font_size = nil
	end
	window:set_config_overrides(overrides)
	local effective = window:effective_config()
	wezterm.log_info("The leader is: " .. effective.leader.key.Char)
	wezterm.log_info(dump(effective.leader))
end)

return {
	font_size = 12.0,
	font = wezterm.font("JetBrainsMono Nerd Font"),
	allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",
	color_scheme = "wezterm_kanagawa",

	initial_cols = 120,
	initial_rows = 50,

	window_padding = { bottom = 4, left = 2, right = 2 },
	leader = { key = "s", mods = "CTRL" },
	keys = {
		{ key = "[", mods = "LEADER", action = "ActivateCopyMode" },
		{
			key = "F12",
			mods = "NONE",
			action = wezterm.action({ EmitEvent = "toggle-leader" }),
		},
		{ key = "v", mods = "LEADER", action = wezterm.action({ PasteFrom = "Clipboard" }) },
		{
			key = "-",
			mods = "LEADER",
			action = wezterm.action({
				SplitVertical = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			key = "\\",
			mods = "LEADER",
			action = wezterm.action({
				SplitHorizontal = { domain = "CurrentPaneDomain" },
			}),
		},
		{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
		{
			key = "c",
			mods = "LEADER",
			action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
		},
		{
			key = "n",
			mods = "LEADER",
			action = wezterm.action({ ActivateTabRelative = 1 }),
		},
		{
			key = "p",
			mods = "LEADER",
			action = wezterm.action({ ActivateTabRelative = -1 }),
		},
		{
			key = "h",
			mods = "LEADER",
			action = wezterm.action({ ActivatePaneDirection = "Left" }),
		},
		{
			key = "l",
			mods = "LEADER",
			action = wezterm.action({ ActivatePaneDirection = "Right" }),
		},
		{
			key = "j",
			mods = "LEADER",
			action = wezterm.action({ ActivatePaneDirection = "Down" }),
		},
		{
			key = "k",
			mods = "LEADER",
			action = wezterm.action({ ActivatePaneDirection = "Up" }),
		},
		{ key = "1", mods = "LEADER", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2", mods = "LEADER", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3", mods = "LEADER", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4", mods = "LEADER", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5", mods = "LEADER", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6", mods = "LEADER", action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7", mods = "LEADER", action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8", mods = "LEADER", action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9", mods = "LEADER", action = wezterm.action({ ActivateTab = -1 }) },
	},
}
