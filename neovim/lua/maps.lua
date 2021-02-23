local map = vim.api.nvim_set_keymap

map('n', '<Space>', '', {})
vim.g.mapleader = " "

options = {noremap = true}
map('n', '<leader>/', ':nohlsearch<cr>', options)
map('n', '<leader>y', '"+y', options)
map('n', '<leader>p', '"+p', options)
map('n', '<leader> ', '<cmd>Buffers<CR>', options)

