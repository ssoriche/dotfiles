local fidget = require("fidget")

fidget.setup({
    text = {
        spinner = "moon",
    },
    sources = {
        gopls = {
            ignore = true,
        },
    },
})
