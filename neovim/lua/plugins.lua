-- Only required if you have packer in your `opt` pack
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use {'wbthomason/packer.nvim', opt = true}

    -- use 'nvim-lua/completion-nvim'
    use 'hrsh7th/nvim-compe'

    use 'nvim-lua/lsp-status.nvim'
    use 'neovim/nvim-lspconfig'
    use {'nvim-treesitter/nvim-treesitter'}
    use {'alexaandru/nvim-lspupdate'}
    use 'glepnir/lspsaga.nvim'

    use 'onsails/lspkind-nvim'
    use 'kosayoda/nvim-lightbulb'

    use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}}
    use {'machakann/vim-sandwich'}

    use {'b3nj5m1n/kommentary'}

    use {'windwp/nvim-autopairs'}
    use {'tpope/vim-eunuch'}
    use {'tpope/vim-obsession'}

    use 'nietiger/halcyon-neovim'
    use '9mm/vim-closer'
    use 'karb94/neoscroll.nvim'

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
    use {"lukas-reineke/indent-blankline.nvim", branch = "lua"}

end)
