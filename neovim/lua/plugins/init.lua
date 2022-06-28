-- Only required if you have packer in your `opt` pack
vim.cmd([[packadd packer.nvim]])

return require("packer").startup(function()
  use({ "wbthomason/packer.nvim", opt = true })

  local config = function(name)
    return string.format("require('plugins.%s')", name)
  end

  local use_with_config = function(path, name)
    use({ path, config = config(name) })
  end

  use({ "L3MON4D3/LuaSnip", config = config("snippets") })
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-emoji",
      "petertriho/cmp-git",
    },
    config = config("cmp"),
  })

  -- use({ "nathom/filetype.nvim", config = config("filetype") })
  use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })
  use({ "akinsho/bufferline.nvim", requires = "kyazdani42/nvim-web-devicons" })
  use({ "stevearc/dressing.nvim" })
  --    use({ "strash/everybody-wants-that-line.nvim", config = config('statusline') })

  -- treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = config("treesitter"),
  })
  use({ "RRethy/nvim-treesitter-textsubjects" })
  use({
    "danymat/neogen",
    config = function()
      require("neogen").setup({
        enabled = true,
      })
    end,
    requires = "nvim-treesitter/nvim-treesitter",
  })

  -- lsp
  use("nvim-lua/lsp-status.nvim")
  use("neovim/nvim-lspconfig")
  use({ "alexaandru/nvim-lspupdate" })
  use({ "jose-elias-alvarez/null-ls.nvim" })

  use("onsails/lspkind-nvim")
  use({ "j-hui/fidget.nvim", config = config("fidget") })

  use({
    "lewis6991/gitsigns.nvim",
    config = config("git"),
    requires = { "nvim-lua/plenary.nvim" },
  })
  use({ "echasnovski/mini.nvim", config = config("mini") })

  use({
    "numToStr/Comment.nvim",
    config = config("comment"),
  })

  use({
    "nmac427/guess-indent.nvim",
    config = function()
      require("guess-indent").setup({})
    end,
  })

  use({
    "windwp/nvim-autopairs",
    config = config("autopairs"),
    wants = "nvim-cmp",
  })

  use({ "tpope/vim-eunuch" })
  use({ "tpope/vim-repeat" })

  use({ "goolord/alpha-nvim", config = config("dashboard") })
  use({ "folke/persistence.nvim", config = config("session") })

  use({
    "ggandor/leap.nvim",
    config = function()
      require("leap").set_default_keymaps()
    end,
  })

  use({ "rafcamlet/nvim-luapad" })
  use({ "mfussenegger/nvim-dap" })
  use({
    "rcarriga/nvim-notify",
    config = function()
      vim.notify = require("notify")
    end,
  })

  -- Themes
  use({
    "nietiger/halcyon-neovim",
    "folke/tokyonight.nvim",
    "marko-cerovac/material.nvim",
    "tjdevries/colorbuddy.nvim",
    "rebelot/kanagawa.nvim",
    "catppuccin/nvim", as = "catppuccin"
  })

  use({ "milisims/nvim-luaref" })
  use({ "nanotee/luv-vimdocs" })

  use({
    "nvim-lualine/lualine.nvim",
    config = config("statusline"),
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
  })

  use_with_config("kyazdani42/nvim-web-devicons", "devicons")

  use({
    "nvim-telescope/telescope.nvim",
    config = config("telescope"),
    requires = { { "nvim-lua/popup.nvim" }, { "nvim-lua/plenary.nvim" } },
  })

  use({ "nvim-telescope/telescope-file-browser.nvim" })
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })

  use("JoosepAlviste/nvim-ts-context-commentstring")

  use({
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({
        plugins = { spelling = { enabled = true, suggestions = 20 } },
      })
    end,
  })

  use({
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  })

  use({
    "folke/todo-comments.nvim",
    config = function()
      require("todo-comments").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  })

  use({
    "folke/lua-dev.nvim",
    config = function()
      require("lua-dev").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      })
    end,
  })

  use({
    "someone-stole-my-name/yaml-companion.nvim",
    requires = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require("telescope").load_extension("yaml_schema")
    end,
  })
  use({ "abecodes/tabout.nvim", wants = { "nvim-treesitter" } })
end)
