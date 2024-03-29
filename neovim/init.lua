vim.g.mapleader = " "

require("config.lazy")
require("options")
require("commands")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("util").version()
    -- require("config.commands")
    require("config.mappings")
  end,
})
