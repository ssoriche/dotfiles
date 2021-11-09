require("persistence").setup()

local u = require("utils")

u.lua_command("SessionDir", 'require("persistence").load()<cr>')
u.lua_command("SessionLast", 'require("persistence").load({ last = true })<cr>')
u.lua_command("SessionDisable", 'require("persistence").stop()<cr>')

u.map("n", "<Leader>qs", "<cmd>SessionDir<CR>")
u.map("n", "<Leader>ql", "<cmd>SessionLast<CR>")
u.map("n", "<Leader>qd", "<cmd>SessionDisable<CR>")
