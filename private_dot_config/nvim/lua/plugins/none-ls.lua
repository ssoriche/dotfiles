local M = {
  "nvimtools/none-ls.nvim",
}

function M.setup(options)
  local nls = require("null-ls")
  nls.setup({
    debounce = 150,
    save_after_format = false,
    sources = {
      nls.builtins.completion.spell,
      nls.builtins.formatting.terraform_fmt,
      nls.builtins.diagnostics.write_good.with({ filetypes = { "markdown", "gitcommit" } }),

      nls.builtins.formatting.fish_indent,
      nls.builtins.diagnostics.shellcheck.with({ diagnostics_format = "#{m} [#{c}]" }),
      nls.builtins.formatting.shfmt.with({
        extra_args = function(params)
          return { "-ci", "-i", vim.api.nvim_buf_get_option(params.bufnr, "shiftwidth") }
        end,
      }),
      nls.builtins.diagnostics.markdownlint,
      -- nls.builtins.diagnostics.luacheck,
      nls.builtins.formatting.prettierd.with({
        filetypes = { "html", "json", "yaml", "markdown", "toml" },
      }),
      nls.builtins.diagnostics.selene.with({
        condition = function(utils)
          return utils.root_has_file({ "selene.toml" })
        end,
      }),
      -- nls.builtins.code_actions.gitsigns,
      nls.builtins.formatting.isort,
      nls.builtins.formatting.black,
      nls.builtins.diagnostics.flake8,
    },
    on_attach = options.on_attach,
    root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", ".git"),
  })
end

function M.has_formatter(ft)
  local sources = require("null-ls.sources")
  local available = sources.get_available(ft, "NULL_LS_FORMATTING")
  return #available > 0
end

return M
