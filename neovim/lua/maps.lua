local map = vim.api.nvim_set_keymap

map('n', '<Space>', '', {})
vim.g.mapleader = " "

options = {noremap = true}
map('n', '<leader>/', ':nohlsearch<cr>', options)
map('n', '<leader>y', '"+y', options)
map('n', '<leader>p', '"+p', options)

map('n', 'Q', '@q', options)
map('v', 'Q', ':norm @q<cr>', options)
map('n', '<bs>', '<c-^>', options)

-- Telescope

-- Trouble
map("n", "<leader>xx", "<cmd>Trouble<cr>", {silent = true, noremap = true})
map("n", "<leader>xw", "<cmd>Trouble lsp_workspace_diagnostics<cr>",
    {silent = true, noremap = true})
map("n", "<leader>xd", "<cmd>Trouble lsp_document_diagnostics<cr>",
    {silent = true, noremap = true})
map("n", "<leader>xl", "<cmd>Trouble loclist<cr>",
    {silent = true, noremap = true})
map("n", "<leader>xq", "<cmd>Trouble quickfix<cr>",
    {silent = true, noremap = true})
