-- Only required if you have packer in your `opt` pack
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use {'wbthomason/packer.nvim', opt = true}

    local config = function(name)
        return string.format("require('plugins.%s')", name)
    end

    local use_with_config = function(path, name)
        use({path, config = config(name)})
    end

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/vim-vsnip',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-nvim-lua',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-emoji',
        },
    }

    use 'nvim-lua/lsp-status.nvim'
    use 'neovim/nvim-lspconfig'
    use {'nvim-treesitter/nvim-treesitter'}
    use {'alexaandru/nvim-lspupdate'}
    use 'glepnir/lspsaga.nvim'

    use 'onsails/lspkind-nvim'

    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}}
    use {'machakann/vim-sandwich'}

    use {'b3nj5m1n/kommentary'}

    use {'windwp/nvim-autopairs'}
    use {'tpope/vim-eunuch'}
    use {'tpope/vim-obsession'}

    use 'nietiger/halcyon-neovim'
    use 'folke/tokyonight.nvim'
    use '9mm/vim-closer'

    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true},
    }

    use {
        'nvim-telescope/telescope.nvim',
        requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}},
    }

    use 'tjdevries/colorbuddy.nvim'
    use 'tjdevries/astronauta.nvim'
    use 'marko-cerovac/material.nvim'
    use "lukas-reineke/indent-blankline.nvim"

    use 'JoosepAlviste/nvim-ts-context-commentstring'

    use {
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup {
                plugins = {spelling = {enabled = true, suggestions = 20}},
            }
        end,
    }

    use {
        "folke/trouble.nvim",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("trouble").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end,
    }

    use {
        "folke/todo-comments.nvim",
        config = function()
            require("todo-comments").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end,
    }

    use {
        "folke/lua-dev.nvim",
        config = function()
            require("lua-dev").setup {
                -- your configuration comes here
                -- or leave it empty to use the default settings
                -- refer to the configuration section below
            }
        end,
    }

    use {
        'abecodes/tabout.nvim',
        wants = {'nvim-treesitter'},
    }

end)
