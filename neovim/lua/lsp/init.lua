local lspconfig = require("lspconfig")
local null_ls = require("lsp.null-ls")
local sumneko = require("lsp.sumneko")
local yamlls = require("lsp.yamlls")
local u = require("utils")

local lsp = vim.lsp

local map = vim.api.nvim_set_keymap

require("lsp.diagnostics").setup()

local popup_opts = { border = "single", focusable = false }

lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.signature_help, popup_opts)
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, popup_opts)

_G.global.lsp = { popup_opts = popup_opts }

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

local on_attach = function(client, bufnr)
    -- commands
    u.lua_command("LspFormatting", "vim.lsp.buf.formatting()")
    u.lua_command("LspHover", "vim.lsp.buf.hover()")
    u.lua_command("LspRename", "vim.lsp.buf.rename()")
    u.lua_command("LspDiagPrev", "vim.diagnostic.goto_prev()")
    u.lua_command("LspDiagNext", "vim.diagnostic.goto_next()")
    u.lua_command("LspDiagLine", "vim.diagnostic.open_float(popup_opts)")
    u.lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")
    u.lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")
    u.lua_command("LspCodeAction", "vim.lsp.buf.code_action()")

    -- bindings
    u.buf_map("n", "gy", ":LspTypeDef<CR>", nil, bufnr)
    u.buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

    -- telescope

    if client.resolved_capabilities.document_formatting then
        u.buf_augroup("LspFormatOnSave", "BufWritePre", "lua vim.lsp.buf.formatting_sync()")
    end

    if client.resolved_capabilities.code_action then
        u.buf_map("n", "<Leader>ca", ":LspAct<CR>", nil, bufnr)
    end

    if client.resolved_capabilities.goto_definition then
        u.buf_map("n", "gd", ":LspDef<CR>", nil, bufnr)
    end
    if client.resolved_capabilities.hover then
        u.buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
    end
    if client.resolved_capabilities.find_references then
        u.buf_map("n", "<Leader>*", ":LspRef<CR>", nil, bufnr)
    end
    if client.resolved_capabilities.rename then
        u.buf_map("n", "<leader>rn", ":LspRename<CR>", nil, bufnr)
    end
    vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, { buffer = bufnr })
    vim.keymap.set("n", "gI", vim.lsp.buf.implementation, { buffer = bufnr })
    u.buf_map("n", "<Leader>a", ":LspDiagLine<CR>", nil, bufnr)
    u.buf_map("n", "[a", ":LspDiagPrev<CR>", nil, bufnr)
    u.buf_map("n", "]a", ":LspDiagNext<CR>", nil, bufnr)
    map(
        "n",
        "<leader>cc",
        "<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>",
        { silent = true, noremap = true }
    )
end

-- https://github.com/golang/tools/tree/master/gopls
lspconfig.gopls.setup({
    on_attach = function(client)
        on_attach(client)
    end,
    settings = { gopls = { gofumpt = true } },
    capabilities = capabilities,
})

lspconfig.pyright.setup({ on_attach = on_attach })

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
