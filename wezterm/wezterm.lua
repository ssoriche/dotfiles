local wezterm = require 'wezterm';
return {
    font_size = 12.0,
    font = wezterm.font("JetBrainsMono Nerd Font"),
    allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",
    color_scheme = "MaterialOcean",

    initial_cols = 120,
    initial_rows = 50,

    window_padding = {bottom = 4, left = 2, right = 2},
    leader = {key = "s", mods = "CTRL"},
    keys = {
        {key = "[", mods = "LEADER", action = "ActivateCopyMode"},
        {
            key = "-",
            mods = "LEADER",
            action = wezterm.action {
                SplitVertical = {domain = "CurrentPaneDomain"},
            },
        },
        {
            key = "\\",
            mods = "LEADER",
            action = wezterm.action {
                SplitHorizontal = {domain = "CurrentPaneDomain"},
            },
        },
        {key = "z", mods = "LEADER", action = "TogglePaneZoomState"},
        {
            key = "c",
            mods = "LEADER",
            action = wezterm.action {SpawnTab = "CurrentPaneDomain"},
        },
        {
            key = "n",
            mods = "LEADER",
            action = wezterm.action {ActivateTabRelative = 1},
        },
        {
            key = "p",
            mods = "LEADER",
            action = wezterm.action {ActivateTabRelative = -1},
        },
        {
            key = "h",
            mods = "LEADER",
            action = wezterm.action {ActivatePaneDirection = "Left"},
        },
        {
            key = "l",
            mods = "LEADER",
            action = wezterm.action {ActivatePaneDirection = "Right"},
        },
        {
            key = "j",
            mods = "LEADER",
            action = wezterm.action {ActivatePaneDirection = "Down"},
        },
        {
            key = "k",
            mods = "LEADER",
            action = wezterm.action {ActivatePaneDirection = "Up"},
        },
    },
}
