local saga = require("lspsaga")

saga.init_lsp_saga({
  -- your configuration
  diagnostic_header = { "😡", "😥", "😤", "😐" },
  symbol_in_winbar = {
    enable = false
  }
})
