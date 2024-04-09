-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Disable cursor keys, I use ctrl-j,k,l,h as cursor keys
-- these mappings set the cursor keys to LazyVim's ctrl-j,k,l,h mappings
vim.keymap.set("n", "<Down>", "<C-w>j")
vim.keymap.set("n", "<Up>", "<C-w>k")
vim.keymap.set("n", "<Right>", "<C-w>l")
vim.keymap.set("n", "<Left>", "<C-w>h")
