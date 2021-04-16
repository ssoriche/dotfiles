local unimpaired = {}
local map = vim.api.nvim_set_keymap

function unimpaired.mapNextFamily(key, cmd)
    options = {noremap = true}
    map('n', '[' .. key, ':' .. cmd .. 'prev<cr>', options)
    map('n', ']' .. key, ':' .. cmd .. 'next<cr>', options)
    map('n', '[' .. string.upper(key), ':' .. cmd .. 'first<cr>', options)
    map('n', ']' .. string.upper(key), ':' .. cmd .. 'last<cr>', options)
end

function unimpaired.gitConflictSearch(reverse)
    local direction = "W"
    if reverse == 1 then direction = "bW" end
    -- local direction = if reverse then "bW" else "W" end
    vim.fn.search([[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]], direction)
end

function unimpaired.setup(opts)
    opts = opts or {}
    unimpaired.mapNextFamily('a', '')
    unimpaired.mapNextFamily('b', 'b')
    unimpaired.mapNextFamily('l', 'l')
    unimpaired.mapNextFamily('q', 'c')
    unimpaired.mapNextFamily('t', 't')

    map('n', '[n', "<cmd>lua require'unimpaired'.gitConflictSearch(1)<cr>",
        {noremap = true})
    map('n', ']n', "<cmd>lua require'unimpaired'.gitConflictSearch(0)<cr>",
        {noremap = true})
end

return unimpaired
