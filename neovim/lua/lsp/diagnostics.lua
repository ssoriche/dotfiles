local M = {}

M.signs = {
    emoji = { Error = "💩", Warn = "🔥", Hint = "", Info = "💡" },
    symbols = { Error = "", Warn = "", Info = "", Hint = "" },
}

M.codes = {
    no_matching_function = {
        message = " Can't find a matching function",
        "redundant-parameter",
        "ovl_no_viable_function_in_call",
    },
    empty_block = {
        message = " That shouldn't be empty here",
        "empty-block",
    },
    missing_symbol = {
        message = " Here should be a symbol",
        "miss-symbol",
    },
    expected_semi_colon = {
        message = " Remember the `;` or `,`",
        "expected_semi_declaration",
        "miss-sep-in-table",
        "invalid_token_after_toplevel_declarator",
    },
    redefinition = {
        message = " That variable was defined before",
        "redefinition",
        "redefined-local",
    },
    no_matching_variable = {
        message = " Can't find that variable",
        "undefined-global",
        "reportUndefinedVariable",
    },
    trailing_whitespace = {
        message = " Remove trailing whitespace",
        "trailing-whitespace",
        "trailing-space",
    },
    unused_variable = {
        message = " Don't define variables you don't use",
        "unused-local",
    },
    unused_function = {
        message = " Don't define functions you don't use",
        "unused-function",
    },
    useless_symbols = {
        message = " Remove that useless symbols",
        "unknown-symbol",
    },
    wrong_type = {
        message = " Try to use the correct types",
        "init_conversion_failed",
    },
    undeclared_variable = {
        message = " Have you delcared that variable somewhere?",
        "undeclared_var_use",
    },
    lowercase_global = {
        message = " Should that be a global? (if so make it uppercase)",
        "lowercase-global",
    },
}

M.borders = {
    single = {
        { "┏", "FloatBorder" },
        { "━", "FloatBorder" },
        { "┓", "FloatBorder" },
        { "┃", "FloatBorder" },
        { "┛", "FloatBorder" },
        { "━", "FloatBorder" },
        { "┗", "FloatBorder" },
        { "┃", "FloatBorder" },
    },

    double = {
        { "╔", "FloatBorder" },
        { "═", "FloatBorder" },
        { "╗", "FloatBorder" },
        { "║", "FloatBorder" },
        { "╝", "FloatBorder" },
        { "═", "FloatBorder" },
        { "╚", "FloatBorder" },
        { "║", "FloatBorder" },
    },

    other = {
        { "🭽", "FloatBorder" },
        { "▔", "FloatBorder" },
        { "🭾", "FloatBorder" },
        { "▕", "FloatBorder" },
        { "🭿", "FloatBorder" },
        { "▁", "FloatBorder" },
        { "🭼", "FloatBorder" },
        { "▏", "FloatBorder" },
    },

    thick = {
        { "▛", "FloatBorder" },
        { "▀", "FloatBorder" },
        { "▜", "FloatBorder" },
        { "▐", "FloatBorder" },
        { "▟", "FloatBorder" },
        { "▄", "FloatBorder" },
        { "▙", "FloatBorder" },
        { "▌", "FloatBorder" },
    },

    thin = {
        { "╭", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╮", "FloatBorder" },
        { "│", "FloatBorder" },
        { "╯", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╰", "FloatBorder" },
        { "│", "FloatBorder" },
    },
}

function M.setup()
    local signs = M.signs.symbols

    for sign, icon in pairs(signs) do
        vim.fn.sign_define("DiagnosticSign" .. sign, {
            text = icon,
            texthl = "Diagnostic" .. sign,
            linehl = false,
            numhl = "Diagnostic" .. sign,
        })
    end

    vim.diagnostic.config({
        float = {
            focusable = false,
            border = M.borders.thin,
            scope = "cursor",
            -- source = true,
            format = function(diagnostic)
                local code = diagnostic.user_data ~= nil and diagnostic.user_data.lsp.code or nil
                -- print("diagnostic:")
                -- print(vim.inspect(diagnostic))
                for _, table in pairs(M.codes) do
                    if vim.tbl_contains(table, code) then
                        return table.message
                    end
                end
                return diagnostic.message
            end,
            header = { "Cursor Diagnostics:", "DiagnosticHeader" },
            pos = 1,
            prefix = function(diagnostic, i, total)
                local icon, highlight
                if diagnostic.severity == 1 then
                    icon = signs.Error
                    highlight = "DiagnosticError"
                elseif diagnostic.severity == 2 then
                    icon = signs.Warn
                    highlight = "DiagnosticWarn"
                elseif diagnostic.severity == 3 then
                    icon = signs.Info
                    highlight = "DiagnosticInfo"
                elseif diagnostic.severity == 4 then
                    icon = signs.Hint
                    highlight = "DiagnosticHint"
                end
                return i .. "/" .. total .. " " .. icon .. "  ", highlight
            end,
        },
        signs = true,
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        -- virtual_text = true,
        severity_sort = true,
    })
end

return M
