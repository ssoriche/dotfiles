local lspconfig = require "lspconfig"

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
vim.cmd [[command! FormatEnable lua FormatToggle(false)]]

_G.formatting = function()
    if not vim.g[string.format("format_disabled_%s", vim.bo.filetype)] then
        vim.lsp.buf.formatting(vim.g[string.format("format_options_%s",
                                                   vim.bo.filetype)] or {})
    end
end

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

local M = {}
M.setup = function(on_attach, capabilities)
  -- https://github.com/mattn/efm-langserver
  lspconfig.efm.setup {
      on_attach = on_attach,
      init_options = {documentFormatting = true},
      settings = {rootMarkers = {".git/", "go.mod"}, languages = languages},
      filetypes = vim.tbl_keys(languages),
  }
end

return M
