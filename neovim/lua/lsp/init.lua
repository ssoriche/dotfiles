require("mason").setup()
require("mason-lspconfig").setup({ automatic_installation = true })
require("neodev").setup({})

local lspconfig = require("lspconfig")
local null_ls = require("lsp.null-ls")
local sumneko = require("lsp.sumneko")
local yamlls = require("lsp.yamlls")
local u = require("utils")

local lsp = vim.lsp

local map = vim.api.nvim_set_keymap


local signs = { Error = "😡", Warn = "😥", Hint = "😤", Info = "😐" }
--[[ local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " } ]]
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local popup_opts = { border = "single", focusable = false }

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)

_G.global.lsp = { popup_opts = popup_opts }

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local on_attach = function(client, bufnr)
    bufnr = bufnr or 0
    -- commands
    vim.api.nvim_create_user_command("LspFormat", function()
        vim.lsp.buf.format({ async = true })
    end, {})
    vim.api.nvim_buf_create_user_command(bufnr, "LspHover", vim.lsp.buf.hover, {})
    vim.api.nvim_buf_create_user_command(bufnr, "LspRename", vim.lsp.buf.rename, {})
    vim.api.nvim_buf_create_user_command(bufnr, "LspDiagPrev", vim.diagnostic.goto_prev, {})
    vim.api.nvim_buf_create_user_command(bufnr, "LspDiagNext", vim.diagnostic.goto_next, {})
    vim.api.nvim_buf_create_user_command(bufnr, "LspDiagLine", vim.diagnostic.open_float, {})
    vim.api.nvim_buf_create_user_command(bufnr, "LspSignatureHelp", vim.lsp.buf.signature_help, {})
    vim.api.nvim_create_user_command("LspTypeDef", vim.lsp.buf.type_definition, {})
    vim.api.nvim_create_user_command("LspCodeAction", vim.lsp.buf.code_action, {})

    -- bindings
    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set("i", "<C-X><C-X>", vim.lsp.buf.signature_help, { buffer = bufnr })

    -- telescope

    if client.supports_method("textDocument/formatting") then
        local augroup = vim.api.nvim_create_augroup("LspFormat", {})
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end,
        })
    end

    vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
    vim.keymap.set("n", "gd", "<cmd>LspDef<cr>", { buffer = bufnr })
    vim.keymap.set("n", "K", "<cmd>LspHover<cr>", { buffer = bufnr })
    vim.keymap.set("n", "<Leader>*", "<cmd>LspRef<CR>", { buffer = bufnr })
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr })
    vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { buffer = bufnr })
    vim.keymap.set("n", "<Leader>a", "<cmd>LspDiagLine<CR>", { buffer = bufnr })
    vim.keymap.set("n", "[a", "<cmd>LspDiagPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "]a", "<cmd>LspDiagNext<CR>", { buffer = bufnr })
    map(
        "n",
        "<leader>cc",
        "<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>",
        { silent = true, noremap = true }
    )
end

-- https://github.com/golang/tools/tree/master/gopls
lspconfig.gopls.setup({
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)
    end,
    settings = { gopls = { gofumpt = true } },
    capabilities = capabilities,
})

lspconfig.pylsp.setup({ on_attach = on_attach })

lspconfig.perlpls.setup({ on_attach = on_attach })

-- https://github.com/theia-ide/typescript-language-server
lspconfig.tsserver.setup({
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        on_attach(client)
    end,
})

-- https://github.com/iamcco/vim-language-server
lspconfig.vimls.setup({ on_attach = on_attach })

-- https://github.com/vscode-langservers/vscode-json-languageserver
lspconfig.jsonls.setup({
    on_attach = on_attach,
    cmd = { "vscode-json-languageserver", "--stdio" },
})

-- https://github.com/joe-re/sql-language-server
lspconfig.sqlls.setup({ on_attach = on_attach })

-- https://github.com/vscode-langservers/vscode-css-languageserver-bin
lspconfig.cssls.setup({ on_attach = on_attach })

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
lspconfig.html.setup({ on_attach = on_attach })

-- https://github.com/bash-lsp/bash-language-server
lspconfig.bashls.setup({ on_attach = on_attach })

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
lspconfig.dockerls.setup({ on_attach = on_attach })

-- https://github.com/hashicorp/terraform-ls
lspconfig.terraformls.setup({
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
        on_attach(client, bufnr)
    end,
    cmd = { "terraform-ls", "serve" },
    filetypes = { "tf" },
})

lspconfig.clangd.setup({ on_attach = on_attach })

lspconfig.julials.setup({})

null_ls.setup(on_attach)
sumneko.setup(on_attach, capabilities)
yamlls.setup(on_attach, capabilities)
