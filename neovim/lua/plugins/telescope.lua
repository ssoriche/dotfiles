return {
  "nvim-telescope/telescope.nvim",
  cmd = { "Telescope" },

  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-file-browser.nvim" },
  },
  keys = {
    {
      "<leader><space>",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Find Buffer",
    },
    -- {
    --   "<leader>fg",
    --   function()
    --     require("telescope.builtin").live_grep()
    --   end,
    --   desc = "Live Grep",
    -- },
    -- {
    --   "<leader>fa",
    --   function()
    --     require("telescope.builtin").grep_string()
    --   end,
    --   desc = "Grep String",
    -- },
  },
  config = function()
    local telescope = require("telescope")
    -- local actions = require("telescope.actions")
    local borderless = true

    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = {
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
        mappings = {
          i = {
            ["<c-t>"] = function(...)
              return require("trouble.providers.telescope").open_with_trouble(...)
            end,
            ["<C-Down>"] = function(...)
              return require("telescope.actions").cycle_history_next(...)
            end,
            ["<C-Up>"] = function(...)
              return require("telescope.actions").cycle_history_prev(...)
            end,
            ["<ESC>"] = function(...)
              return require("telescope.actions").close(...)
            end,
          },
        },
        prompt_prefix = " ",
        selection_caret = " ",
        winblend = borderless and 0 or 10,
      },
    })
    telescope.load_extension("file_browser")
    telescope.load_extension("fzf")
  end,
}
