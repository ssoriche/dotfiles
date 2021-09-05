local lspconfig = require "lspconfig"

local map = vim.api.nvim_set_keymap

local lspkind = require('lspkind')
local cmp = require('cmp')
cmp.setup {
    snippet = {expand = function(args) vim.fn["vsnip#anonymous"](args.body) end},
    sources = {
        {name = 'path'},
        {name = 'buffer'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lua'},
    },
    mapping = {
        ['<CR>'] = cmp.mapping.confirm({
            -- TODO: I may infact what Insert here, sometimes a variable gets
            -- replaced when completing and I dont' want that
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    },
    formatting = {
        format = function(entry, vim_item)
            vim_item.kind = lspkind.presets.default[vim_item.kind]
            return vim_item
        end,
    },
}

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

vim.lsp.handlers["textDocument/formatting"] =
    function(err, _, result, _, bufnr)
        if err ~= nil or result == nil then return end
        if not vim.api.nvim_buf_get_option(bufnr, "modified") then
            local view = vim.fn.winsaveview()
            vim.lsp.util.apply_text_edits(result, bufnr)
            vim.fn.winrestview(view)
            if bufnr == vim.api.nvim_get_current_buf() then
                vim.cmd [[noautocmd :update]]
            end
        end
    end

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    function(...)
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            signs = true,
            underline = false,
            update_in_insert = false,
        })(...)
        pcall(vim.lsp.diagnostic.set_loclist, {open = false})
    end

local format_options_prettier = {
    tabWidth = 4,
    singleQuote = true,
    trailingComma = "all",
    configPrecedence = "prefer-file",
}
vim.g.format_options_typescript = format_options_prettier
vim.g.format_options_javascript = format_options_prettier
vim.g.format_options_typescriptreact = format_options_prettier
vim.g.format_options_javascriptreact = format_options_prettier
vim.g.format_options_json = format_options_prettier
vim.g.format_options_css = format_options_prettier
vim.g.format_options_scss = format_options_prettier
vim.g.format_options_html = format_options_prettier
vim.g.format_options_yaml = format_options_prettier
vim.g.format_options_markdown = format_options_prettier

FormatToggle = function(value)
    vim.g[string.format("format_disabled_%s", vim.bo.filetype)] = value
end
vim.cmd [[command! FormatDisable lua FormatToggle(true)]]
vim.cmd [[command! FormatEndable lua FormatToggle(false)]]

_G.formatting = function()
    if not vim.g[string.format("format_disabled_%s", vim.bo.filetype)] then
        vim.lsp.buf.formatting(vim.g[string.format("format_options_%s",
                                                   vim.bo.filetype)] or {})
    end
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

-- https://github.com/sumneko/lua-language-server
-- require("nlua.lsp.nvim").setup(
--     lspconfig,
--     {
--         on_attach = on_attach,
--         cmd = {"lua-language-server"}
--     }
-- )

local function get_lua_runtime()
    local result = {}
    for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
        local lua_path = path .. "/lua/"
        if vim.fn.isdirectory(lua_path) then result[lua_path] = true end
    end
    result[vim.fn.expand("$VIMRUNTIME/lua")] = true
    result[vim.fn.expand("~/build/neovim/src/nvim/lua")] = true

    return result
end

local luadev = require"lua-dev".setup({
    lspconfig = {cmd = {"lua-language-server"}},
})
lspconfig.sumneko_lua.setup(luadev)

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

-- local vint = require "efm/vint"
local luafmt = require "lsp/efm/luafmt"
local black = require "lsp/efm/black"
local isort = require "lsp/efm/isort"
local flake8 = require "lsp/efm/flake8"
local mypy = require "lsp/efm/mypy"
local prettier = require "lsp/efm/prettier"
local eslint = require "lsp/efm/eslint"
local shellcheck = require "lsp/efm/shellcheck"
local terraform = require "lsp/efm/terraform"
local misspell = require "lsp/efm/misspell"

local languages = {
    ["="] = {misspell},
    lua = {luafmt},
    sh = {shellcheck},
    -- vim = {vint},
    -- python = {black, isort, flake8, mypy},
    typescript = {prettier, eslint},
    javascript = {prettier, eslint},
    -- typescriptreact = {prettier, eslint},
    -- javascriptreact = {prettier, eslint},
    yaml = {prettier},
    json = {prettier},
    -- html = {prettier},
    -- scss = {prettier},
    -- css = {prettier},
    markdown = {prettier},
    -- tf = {terraform}
}

-- https://github.com/mattn/efm-langserver
lspconfig.efm.setup {
    on_attach = on_attach,
    init_options = {documentFormatting = true},
    settings = {rootMarkers = {".git/", "go.mod"}, languages = languages},
    filetypes = vim.tbl_keys(languages),
}

lspconfig.clangd.setup {on_attach = on_attach}

require('lsp/lspsaga')
