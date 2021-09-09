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
require("treesitter")
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

local actions = require('telescope.actions')
require'telescope'.setup {
    config = {
        layout_strategy = 'flex',
        scroll_strategy = 'cycle',
        mappings = {i = {["<esc>"] = actions.close}},
        winblend = 0,
        layout_defaults = {
            horizontal = {
                width_padding = 0.1,
                height_padding = 0.1,
                preview_width = 0.6,
                -- mirror = false,
            },
            vertical = {
                width_padding = 0.05,
                height_padding = 1,
                preview_height = 0.5,
                -- mirror = true,
            },
        },
        file_ignore_patterns = {'tags'},
    },
}

require'unimpaired'.setup()
require('tabout').setup()
