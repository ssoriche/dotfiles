package.path = "/usr/local/share/lua/5.3/?.lua;/usr/local/share/lua/5.3/?/init.lua;" .. package.path
package.cpath = "/user/local/lib/lua/5.3/?.so" .. package.cpath

hs.loadSpoon("SpoonInstall")
hs.loadSpoon("EmmyLua")

spoon.SpoonInstall.repos.zzspoons = {
  url = "https://github.com/zzamboni/zzSpoons",
  desc = "zzamboni's spoon repository",
}

local hyper = { "cmd", "alt", "ctrl" }
local shift_hyper = { "cmd", "alt", "ctrl", "shift" }
local ctrl_cmd = { "cmd", "ctrl" }

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
    s.plugins.urlformats:providersTable({
      gh = { name = "GitHub", url = "https://github.com/%s" },
      go = { name = "golinks", url = "https://go.metroplex.coloredblocks.net/%s" },
    })
    s:refreshAllCommands()
  end,
  start = true,
})

local function appID(app)
  return hs.application.infoForBundlePath(app)['CFBundleIdentifier']
end

-- local chromeBrowser = appID('/Applications/Google Chrome.app')
local meetBrowser = appID('/Users/shawns/Applications/Chrome Apps.localized/Google Meet.app')
local firefoxBrowser = appID('/Applications/Firefox Developer Edition.app')

DefaultBrowser = firefoxBrowser

Install:andUse("URLDispatcher",
  {
    config = {
      url_patterns = {
        { "https://meet.google.com", meetBrowser }
      },
      default_handler = DefaultBrowser
    },
    start = true,
  }
)


Install:andUse("Caffeine", {
  start = true,
  hotkeys = {
    toggle = { hyper, "1" },
  },
  --                 fn = BTT_caffeine_widget,
})
