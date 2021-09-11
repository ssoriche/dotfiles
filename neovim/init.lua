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

g.indent_blankline_char = "│"

require('plugins')
require('lsp')
require('settings')
require('maps')

--[[ g.material_style = 'deep ocean'
g.material_italics = 1
require('material').set() ]]

g.tokyonight_style = "night"
g.tokyonight_transparent = true
vim.cmd [[colorscheme tokyonight]]

--[[ local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'maintained', highlight = {enable = true}} ]]

-- Configure treesitter, kommentary, and nvim-ts-context-commentstring
-- https://github.com/JoosepAlviste/nvim-ts-context-commentstring#kommentary
require'nvim-treesitter.configs'.setup {
    context_commentstring = {enable = true, enable_autocmd = false},
}

require('kommentary.config').configure_language('typescriptreact', {
    hook_function = function()
        require('ts_context_commentstring.internal').update_commentstring()
    end,
})

require'unimpaired'.setup()
require('tabout').setup()
