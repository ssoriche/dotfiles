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

    use 'onsails/lspkind-nvim'
    use 'kosayoda/nvim-lightbulb'

    use {'airblade/vim-gitgutter'}
    -- use {'dense-analysis/ale'}
    use {'machakann/vim-sandwich'}

    use {'b3nj5m1n/kommentary'}

    -- use {'tpope/vim-surround'}
    -- use {'tpope/vim-commentary'}
    use {'tpope/vim-unimpaired'}
    use {'tpope/vim-endwise'}
    use {'tpope/vim-eunuch'}
    use {'tpope/vim-obsession'}

    use 'nietiger/halcyon-neovim'
    use '9mm/vim-closer'

    use {
        'hoob3rt/lualine.nvim',
        -- requires = {'kyazdani42/nvim-web-devicons', opt = true},
        requires = {'kyazdani42/nvim-web-devicons'},
        config = function()
            local lualine = require('lualine')
            lualine.theme = 'powerline'
            -- lualine.separator = '|'
            -- lualine.sections = {
            --   lualine_a = { 'mode' },
            --   lualine_b = { 'branch' },
            --   lualine_c = { 'filename' },
            --   lualine_x = { 'encoding', 'fileformat', 'filetype' },
            --   lualine_y = { 'progress' },
            --   lualine_z = { 'location'  },
            -- }
            -- lualine.inactive_sections = {
            --   lualine_a = {  },
            --   lualine_b = {  },
            --   lualine_c = { 'filename' },
            --   lualine_x = { 'location' },
            --   lualine_y = {  },
            --   lualine_z = {   }
            -- }
            lualine.extensions = {'fzf'}
            lualine.status()
        end,
    }

    use {
        'ojroques/nvim-lspfuzzy',
        requires = {
            {'junegunn/fzf'},
            {'junegunn/fzf.vim'}, -- to enable preview (optional)
        },
    }

end)
