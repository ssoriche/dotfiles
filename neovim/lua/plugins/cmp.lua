local cmp = require("cmp")

local lspkind = require("lspkind")

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    sources = {
        { name = "nvim_lua" },

        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer", keyword_length = 5 },
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
