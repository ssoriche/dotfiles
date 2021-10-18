local cmp = require("cmp")

local u = require("utils")
local lspkind = require("lspkind")

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    sources = {
        { name = "path" },
        { name = "buffer" },
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
    },
    mapping = {
        ["<CR>"] = cmp.mapping.confirm({
            -- TODO: I may infact what Insert here, sometimes a variable gets
            -- replaced when completing and I dont' want that
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    },
    formatting = {
        format = lspkind.cmp_format(),
    },
})
