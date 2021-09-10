local lspconfig = require "lspconfig"
local efm = require('lsp/efm')
local sumneko = require("lsp.sumneko")

local map = vim.api.nvim_set_keymap

-- Setup buffer configuration (nvim-lua source only enables in Lua filetype).
vim.api.nvim_command([[autocmd FileType lua lua require'cmp'.setup.buffer {
sources = {
{ name = 'buffer' },
{ name = 'nvim_lua' },
},
}]])

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

vim.fn.sign_define("LspDiagnosticsSignError",
                   {text = "x", texthl = "LspDiagnosticsDefaultError"})
vim.fn.sign_define("LspDiagnosticsSignWarning",
                   {text = "w", texthl = "LspDiagnosticsDefaultWarning"})
vim.fn.sign_define("LspDiagnosticsSignInformation",
                   {text = "i", texthl = "LspDiagnosticsDefaultInformation"})
vim.fn.sign_define("LspDiagnosticsSignHint",
                   {text = "h", texthl = "LspDiagnosticsDefaultHint"})

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    function(...)
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            signs = true,
            underline = false,
            update_in_insert = false,
        })(...)
        pcall(vim.lsp.diagnostic.set_loclist, {open = false})
    end

local on_attach = function(client)
    if client.resolved_capabilities.code_action then
        map("n", "<leader>ca",
            "<cmd>lua require'lspsaga.codeaction'.code_action()<CR>",
            {silent = true, noremap = true})
        map("v", "<leader>ca",
            ":<C-U>lua require'lspsaga.codeaction'.range_code_action()<CR>",
            {silent = true, noremap = true})
    end

    if client.resolved_capabilities.document_formatting then
        vim.cmd [[augroup Format]]
        vim.cmd [[autocmd! * <buffer>]]
        vim.cmd [[autocmd BufWritePost <buffer> lua formatting()]]
        vim.cmd [[augroup END]]
    end
    if client.resolved_capabilities.goto_definition then
        map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>",
            {silent = true, noremap = true})
        map("n", "<leader>gd",
            "<cmd>lua require'lspsaga.provider'.preview_definition()<CR>",
            {silent = true, noremap = true})
        map("n", "<C-f>",
            "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>",
            {silent = true, noremap = true})
        map("n", "<C-b>",
            "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>",
            {silent = true, noremap = true})
    end
    if client.resolved_capabilities.hover then
        map("n", "<CR>",
            "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>",
            {silent = true, noremap = true})
        map("n", "<C-f>",
            "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>",
            {silent = true, noremap = true})
        map("n", "<C-b>",
            "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>",
            {silent = true, noremap = true})
    end
    if client.resolved_capabilities.find_references then
        map("n", "<Leader>*", "<cmd>Trouble lsp_references<CR>",
            {silent = true, noremap = true})
    end
    if client.resolved_capabilities.rename then
        map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>",
            {silent = true, noremap = true})
    end
    map("n", "<leader>cd",
        "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<CR>",
        {silent = true, noremap = true})
    map("n", "<leader>cc",
        "<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostics()<CR>",
        {silent = true, noremap = true})
    map("n", "[e",
        "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()<CR>",
        {silent = true, noremap = true})
    map("n", "]e",
        "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()<CR>",
        {silent = true, noremap = true})
    map("n", "gs",
        "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>",
        {silent = true, noremap = true})
end

function _G.activeLSP()
    local servers = {}
    for _, lsp in pairs(vim.lsp.get_active_clients()) do
        table.insert(servers, {name = lsp.name, id = lsp.id})
    end
    _G.dump(servers)
end
function _G.bufferActiveLSP()
    local servers = {}
    for _, lsp in pairs(vim.lsp.buf_get_clients()) do
        table.insert(servers, {name = lsp.name, id = lsp.id})
    end
    _G.dump(servers)
end

-- https://github.com/golang/tools/tree/master/gopls
lspconfig.gopls.setup {
    on_attach = function(client) on_attach(client) end,
    settings = {gopls = {gofumpt = true}},
    capabilities = capabilities,
}

lspconfig.pyright.setup {on_attach = on_attach}

lspconfig.perlpls.setup {on_attach = on_attach}

-- https://github.com/theia-ide/typescript-language-server
lspconfig.tsserver.setup {
    on_attach = function(client)
        client.resolved_capabilities.document_formatting = false
        on_attach(client)
    end,
}

-- https://github.com/iamcco/vim-language-server
lspconfig.vimls.setup {on_attach = on_attach}

-- https://github.com/vscode-langservers/vscode-json-languageserver
lspconfig.jsonls.setup {
    on_attach = on_attach,
    cmd = {"vscode-json-languageserver", "--stdio"},
}

-- https://github.com/redhat-developer/yaml-language-server
lspconfig.yamlls.setup {
    on_attach = on_attach,
    settings = {yaml = {schemas = {kubernetes = "*.yaml"}}},
}

-- https://github.com/joe-re/sql-language-server
lspconfig.sqlls.setup {on_attach = on_attach}

-- https://github.com/vscode-langservers/vscode-css-languageserver-bin
lspconfig.cssls.setup {on_attach = on_attach}

-- https://github.com/vscode-langservers/vscode-html-languageserver-bin
lspconfig.html.setup {on_attach = on_attach}

-- https://github.com/bash-lsp/bash-language-server
lspconfig.bashls.setup {on_attach = on_attach}

-- https://github.com/rcjsuen/dockerfile-language-server-nodejs
lspconfig.dockerls.setup {on_attach = on_attach}

-- https://github.com/hashicorp/terraform-ls
lspconfig.terraformls.setup {
    on_attach = on_attach,
    cmd = {"terraform-ls", "serve"},
    filetypes = {"tf"},
}

lspconfig.clangd.setup {on_attach = on_attach}

efm.setup(on_attach, capabilities)
sumneko.setup(on_attach, capabilities)

require('lsp/lspsaga')
