local u = require("utils")

local gitsigns = require('gitsigns')

gitsigns.setup({
    word_diff = true,
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
    },
    current_line_blame_formatter_opts = {relative_time = false},
})
