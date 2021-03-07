local map = vim.api.nvim_set_keymap

function mapNextFamily(key, cmd)
    options = {noremap = true}
    map('n', '[' .. key, ':' .. cmd .. 'prev<cr>', options)
    map('n', ']' .. key, ':' .. cmd .. 'next<cr>', options)
    map('n', '[' .. string.upper(key), ':' .. cmd .. 'first<cr>', options)
    map('n', ']' .. string.upper(key), ':' .. cmd .. 'last<cr>', options)
end

mapNextFamily('a', '')
mapNextFamily('b', 'b')
mapNextFamily('l', 'l')
mapNextFamily('q', 'c')
mapNextFamily('t', 't')
