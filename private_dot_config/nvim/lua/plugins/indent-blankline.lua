local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufReadPre",
  main = "ibl",
  -- config = {
  --   buftype_exclude = { "terminal", "nofile" },
  --   filetype_exclude = {
  --     "help",
  --     "startify",
  --     "dashboard",
  --     "packer",
  --     "neogitstatus",
  --     "NvimTree",
  --     "neo-tree",
  --     "Trouble",
  --   },
  -- char = "▏",
  -- context_patterns = {
  --   "class",
  --   "return",
  --   "function",
  --   "method",
  --   "^if",
  --   "^while",
  --   "jsx_element",
  --   "^for",
  --   "^object",
  --   "^table",
  --   "block",
  --   "arguments",
  --   "if_statement",
  --   "else_clause",
  --   "jsx_element",
  --   "jsx_self_closing_element",
  --   "try_statement",
  --   "catch_clause",
  --   "import_statement",
  --   "operation_type",
  -- },
  -- },
}

function M.config()
  require("ibl").setup()
end

return M
