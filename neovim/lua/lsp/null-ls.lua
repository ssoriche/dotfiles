local null_ls = require("null-ls")
local b = null_ls.builtins

local sources = {
    b.completion.spell,
    b.formatting.prettierd.with({
        filetypes = { "html", "json", "yaml", "markdown", "toml" },
    }),
    b.formatting.trim_whitespace.with({ filetypes = { "tmux", "teal", "zsh" } }),
    b.formatting.shfmt.with({
        extra_args = function(params)
            return { "-ci", "-i", vim.api.nvim_buf_get_option(params.bufnr, "shiftwidth") }
        end,
    }),
    b.formatting.terraform_fmt,
    b.diagnostics.write_good.with({ filetypes = { "markdown", "gitcommit" } }),
    b.diagnostics.markdownlint,
    b.diagnostics.teal,
    b.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
}

local M = {}
M.setup = function(on_attach)
    null_ls.setup({ on_attach = on_attach, sources = sources, debug = true })
end

return M
