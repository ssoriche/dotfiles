local cmd = vim.cmd -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn -- to call Vim functions e.g. fn.bufnr()
local g = vim.g -- a table to access global variables
local execute = vim.api.nvim_command

local install_path = fn.stdpath("data") .. "/site/pack/packer/opt/packer.nvim"

if fn.empty(fn.glob(install_path)) > 0 then
    execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
    execute("packadd packer.nvim")
end

_G.global = {}
_G.global.yaml = {}

g.indent_blankline_char = "│"
g.do_filetype_lua = 1
g.did_load_filetypes = 0

require("plugins")
require("lsp")
require("settings")
require("maps")

--[[ g.material_style = 'deep ocean'
g.material_italics = 1
require('material').set() ]]

g.tokyonight_style = "night"
g.tokyonight_transparent = true
vim.cmd("colorscheme kanagawa")

--[[ local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'maintained', highlight = {enable = true}} ]]

require("unimpaired").setup()
require("tabout").setup()
require("fidget").setup()
