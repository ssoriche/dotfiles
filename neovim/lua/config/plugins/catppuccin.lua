local M = {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 999,
}

function M.config()
  local catppuccin = require("catppuccin")
  catppuccin.setup({
    flavour = "mocha",
    integrations = {
      cmp = true,
      gitsigns = true,
      leap = true,
      lsp_trouble = true,
      mini = true,
      mason = true,
      notify = true,
      telescope = true,
      which_key = true,
    }
  })

  vim.cmd.colorscheme("catppuccin")
end

return M
