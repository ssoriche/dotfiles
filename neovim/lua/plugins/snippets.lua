local ls = require("luasnip")
local types = require("luasnip.util.types")

ls.config.set_config({
    history = true,
    updateevents = "TextChanged,TextChangedI",

    enable_autosnippets = true,
    ext_opts = {
        [types.choiceNode] = {
            active = { virt_text = { { "<-", "Error" } } },
        },
    },
})

local s = ls.s
local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node
local rep = require("luasnip.extras").rep

vim.keymap.set({ "i", "s" }, "<Up>", function()
    if ls.expand_or_jumpable() then
        ls.expand_or_jump()
    end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<Down>", function()
    if ls.jumpable(-1) then
        ls.jump(-1)
    end
end, { silent = true })

vim.keymap.set("i", "<c-l>", function()
    if ls.choice_active() then
        ls.change_choice(1)
    end
end)

vim.keymap.set("n", "<leader>S", "<cmd>source ~/.config/nvim/lua/plugins/luasnip.lua<CR>")

ls.snippets = {
    all = {},
    lua = {
        ls.parser.parse_snippet("lf", "local $1 = function($2)\n  $0\nend"),
        s("req", fmt("local {} = require('{}')", { i(1, "default"), rep(1) })),
    },
}
