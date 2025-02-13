return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>fl", LazyVim.pick("files", { root = false, cwd = vim.fn.expand("%:p:h") }), desc = "Find Local Files" },
  },
}
