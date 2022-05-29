local cmp = require("cmp")

local lspkind = require("lspkind")

cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    sources = {
        { name = "nvim_lua" },

        { name = "nvim_lsp" },
        { name = "path" },
        { name = "luasnip" },
        { name = "buffer", keyword_length = 5 },
    },
    mapping = {
        ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item()),
        ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item()),
        ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
        }),
        ["<Up>"] = cmp.config.disable,
        ["<Down>"] = cmp.config.disable,
        ["<Left>"] = cmp.config.disable,
        ["<Right>"] = cmp.config.disable,
    },
    formatting = {
        format = lspkind.cmp_format(),
    },
    experimental = {
        native_menu = false,
        ghost_test = true,
    },
})
