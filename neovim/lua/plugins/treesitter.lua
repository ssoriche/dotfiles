require("nvim-treesitter.configs").setup({
    ensure_installed = "all",
    ignore_install = { "haskell" },
    highlight = { enable = true },
    indent = { enable = true },
    refactor = { highlight_definitions = { enable = true } },
    textobjects = {
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            },
        },
        -- lsp_interop = {
        --     enable = false,
        --     peek_definition_code = {
        --         ["df"] = "@function.outer",
        --         ["dF"] = "@class.outer"
        --     }
        -- }
    },
    -- plugins
    autopairs = { enable = true },
    context_commentstring = { enable = true },
    textsubjects = {
        enable = true,
        keymaps = {
            ["."] = "textsubjects-smart",
            [";"] = "textsubjects-container-outer",
        },
    },
    autotag = { enable = true },
})
