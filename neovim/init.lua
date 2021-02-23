local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local execute = vim.api.nvim_command

local install_path = fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
    execute('!git clone https://github.com/wbthomason/packer.nvim ' ..
                install_path)
    execute 'packadd packer.nvim'
end

require('plugins')
require('lsp')
require("treesitter")
require('settings')
require('maps')

cmd 'colorscheme halcyon' -- Put your favorite colorscheme here

local lualine = require('lualine')
lualine.status()
lualine.options.theme = 'jellybeans'
lualine.extensions = {'fzf'}

--[[ local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'maintained', highlight = {enable = true}} ]]

require'nvim-web-devicons'.setup {
    -- your personnal icons can go here (to override)
    -- DevIcon will be appended to `name`
    -- override = {
    --  zsh = {
    --    icon = "",
    --    color = "#428850",
    --    name = "Zsh"
    --  }
    -- };
    -- globally enable default icons (default to false)
    -- will get overriden by `get_icons` option
    default = true,
}

local saga = require 'lspsaga'
saga.init_lsp_saga {border_style = 1}
