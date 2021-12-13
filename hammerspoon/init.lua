package.path = "/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;" .. package.path
package.cpath = "/user/local/lib/lua/5.3/?.so" .. package.cpath

hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.repos.zzspoons = {
	url = "https://github.com/zzamboni/zzSpoons",
	desc = "zzamboni's spoon repository",
}

spoon.SpoonInstall.use_syncinstall = true

Install = spoon.SpoonInstall

Install:andUse("TextClipboardHistory", {
	-- disable = true,
	config = {
		show_in_menubar = false,
	},
	hotkeys = {
		toggle_clipboard = { { "cmd", "alt" }, "v" },
	},
	start = true,
})

Install:andUse("Seal", {
	-- hotkeys = { show = { {"cmd", "ctrl" }, "space" } },
	hotkeys = { show = { { "cmd" }, "space" } },
	fn = function(s)
		s:loadPlugins({ "apps", "calc", "safari_bookmarks", "screencapture", "useractions", "urlformats" })
		s.plugins.safari_bookmarks.always_open_with_safari = false
		s.plugins.useractions.actions = {
			["Hammerspoon docs webpage"] = {
				url = "https://hammerspoon.org/docs/",
				icon = hs.image.imageFromName(hs.image.systemImageNames.ApplicationIcon),
			},
		}
		s.plugins.urlformats:providersTable({ gh = { name = "GitHub", url = "https://github.com/%s" } })
		s:refreshAllCommands()
	end,
	start = true,
})

--------------------------------
-- START VIM CONFIG
--------------------------------
local VimMode = hs.loadSpoon("VimMode")
local vim = VimMode:new()

-- Configure apps you do *not* want Vim mode enabled in
-- For example, you don't want this plugin overriding your control of Terminal
-- vim
vim
	:disableForApp("Code")
	:disableForApp("zoom.us")
	:disableForApp("iTerm")
	:disableForApp("iTerm2")
	:disableForApp("Terminal")
	:disableForApp("WezTerm")
-- :disableForApp("Google Chrome")

-- If you want the screen to dim (a la Flux) when you enter normal mode
-- flip this to true.
vim:shouldDimScreenInNormalMode(false)

-- If you want to show an on-screen alert when you enter normal mode, set
-- this to true
vim:shouldShowAlertInNormalMode(true)

-- You can configure your on-screen alert font
vim:setAlertFont("Courier New")

-- Enter normal mode by typing a key sequence
--vim:enterWithSequence('jk')

-- if you want to bind a single key to entering vim, remove the
-- :enterWithSequence('jk') line above and uncomment the bindHotKeys line
-- below:
--
-- To customize the hot key you want, see the mods and key parameters at:
--   https://www.hammerspoon.org/docs/hs.hotkey.html#bind
--
-- vim:bindHotKeys({ enter = { {'ctrl'}, ';' } })
vim:bindHotKeys({ enter = { { "ctrl" }, ";" } })

vim:useFallbackMode("Google Chrome")

--------------------------------
-- END VIM CONFIG
--------------------------------
