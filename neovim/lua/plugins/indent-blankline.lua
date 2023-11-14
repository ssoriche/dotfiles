local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufReadPre",
  main = "ibl",
}

function M.config()
  require("ibl").setup()
end

return M
