local map = vim.api.nvim_set_keymap

map('n', '<Space>', '', {})
vim.g.mapleader = " "

options = {noremap = true}
map('n', '<leader>/', ':nohlsearch<cr>', options)
map('n', '<leader>y', '"+y', options)
map('n', '<leader>p', '"+p', options)

-- Telescope
local builtin = "<cmd>lua require('telescope.builtin')"
map('n', '<leader> ', builtin .. '.buffers()<CR>', options)
map('n', '<leader>ff', builtin .. '.find_files()<CR>', options)
map('n', '<leader>of', builtin .. '.oldfiles()<CR>', options)
