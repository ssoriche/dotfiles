local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
}

function M.config()
  require("lualine").setup({
    options = {
      theme = 'catppuccin',
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = { "dashboard", "lazy", "alpha" },
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        -- winbar = 100,
      },
    },
    sections = {
      lualine_a = { M.fmt_branch },
      lualine_b = { M.diagnostics },
      lualine_c = {},
      lualine_x = { M.diff },
      lualine_y = { M.position, M.filetype },
      lualine_z = { M.spaces, M.mode },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    tabline = {},
    extensions = {},
  })
end

local hl_str = function(str, hl_cur, hl_after)
  if hl_after == nil then
    return "%#" .. hl_cur .. "#" .. str .. "%*"
  end
  return "%#" .. hl_cur .. "#" .. str .. "%*" .. "%#" .. hl_after .. "#"
end

M.default = {
  float = true,
  separator = "bubble", -- bubble | triangle
  ---@type any
  colorful = true,
  separator_icon = { left = "", right = " " },
  thin_separator_icon = { left = "", right = " " },
  -- separator_icon = { left = "█", right = "█" },
  -- thin_separator_icon = { left = " ", right = " " },
}

local function hide_in_width()
  return vim.fn.winwidth(0) > 85
end

M.icons = {
  diagnostics = {
    Error = "",
    Warn = "",
    Hint = "",
    Info = "",
  },
  git = {
    added = "",
    modified = "",
    removed = "",
  },
  kinds = {
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = " ",
    Null = "ﳠ ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
  },
  ui = {
    Pencil = "",
    Bug = "",
  },
}

local prev_branch = ""
M.fmt_branch = {
  "branch",
  icons_enabled = false,
  icon = hl_str("", "SLGitIcon", "SLBranchName"),
  colored = false,
  fmt = function(str)
    if vim.bo.filetype == "toggleterm" then
      str = prev_branch
    elseif str == "" or str == nil then
      str = "!=vcs"
    end
    prev_branch = str
    local icon = hl_str("  ", "SLGitIcon", "SLBranchName")
    return hl_str(M.default.separator_icon.left, "SLSeparator")
        .. hl_str(icon, "SLGitIcon")
        .. hl_str(str, "SLBranchName")
        .. hl_str(M.default.separator_icon.right, "SLSeparator", "SLSeparator")
  end,
}

M.position = function()
  -- print(vim.inspect(config.separator_icon))
  local current_line = vim.fn.line(".")
  local current_column = vim.fn.col(".")
  local left_sep = hl_str(M.default.separator_icon.left, "SLSeparator")
  local right_sep = hl_str(M.default.separator_icon.right, "SLSeparator", "SLSeparator")
  local str = "Ln " .. current_line .. ", Col " .. current_column
  return left_sep .. hl_str(str, "SLPosition", "SLPosition") .. right_sep
end

M.spaces = function()
  local left_sep = hl_str(M.default.separator_icon.left, "SLSeparator")
  local right_sep = hl_str(M.default.separator_icon.right, "SLSeparator", "SLSeparator")
  local str = "Spaces: " .. vim.api.nvim_get_option_value("shiftwidth")
  return left_sep .. hl_str(str, "SLShiftWidth", "SLShiftWidth") .. right_sep
end

M.diagnostics = function()
  local function nvim_diagnostic()
    local diagnostics = vim.diagnostic.get(0)
    local count = { 0, 0, 0, 0 }
    for _, diagnostic in ipairs(diagnostics) do
      count[diagnostic.severity] = count[diagnostic.severity] + 1
    end
    return count[vim.diagnostic.severity.ERROR],
        count[vim.diagnostic.severity.WARN],
        count[vim.diagnostic.severity.INFO],
        count[vim.diagnostic.severity.HINT]
  end

  local error_count, warn_count, info_count, hint_count = nvim_diagnostic()
  local error_hl = hl_str(M.icons.diagnostics.Error .. " " .. error_count, "SLError", "SLError")
  local warn_hl = hl_str(M.icons.diagnostics.Warn .. " " .. warn_count, "SLWarning", "SLWarning")
  local info_hl = hl_str(M.icons.diagnostics.Info .. " " .. info_count, "SLInfo", "SLInfo")
  local hint_hl = hl_str(M.icons.diagnostics.Hint .. " " .. hint_count, "SLInfo", "SLInfo")
  local left_sep = hl_str(M.config.thin_separator_icon.left, "SLSeparator")
  local right_sep = hl_str(M.config.thin_separator_icon.right, "SLSeparator", "SLSeparator")
  return left_sep .. error_hl .. " " .. warn_hl .. " " .. hint_hl .. right_sep
end

M.diff = {
  "diff",
  colored = true,
  diff_color = {
    added = "SLDiffAdd",
    modified = "SLDiffChange",
    removed = "SLDiffDelete",
  },
  symbols = {
    added = M.icons.git.added .. " ",
    modified = M.icons.git.modified .. " ",
    removed = M.icons.git.removed .. " ",
  }, -- changes diff symbols
  fmt = function(str)
    if str == "" then
      return ""
    end
    local left_sep = hl_str(M.default.thin_separator_icon.left, "SLSeparator")
    local right_sep = hl_str(M.default.thin_separator_icon.right, "SLSeparator", "SLSeparator")
    return left_sep .. str .. right_sep
  end,
  cond = hide_in_width,
}

M.mode = {
  "mode",
  fmt = function(str)
    local left_sep = hl_str(M.default.separator_icon.left, "SLSeparator", "SLPadding")
    local right_sep = hl_str(M.default.separator_icon.right, "SLSeparator", "SLPadding")
    return left_sep .. hl_str(str, "SLMode") .. right_sep
  end,
}

local prev_filetype = ""
M.filetype = {
  "filetype",
  icons_enabled = false,
  icons_only = false,
  fmt = function(str)
    local ui_filetypes = {
      "help",
      "packer",
      "neogitstatus",
      "NvimTree",
      "Trouble",
      "lir",
      "Outline",
      "spectre_panel",
      "toggleterm",
      "DressingSelect",
      "neo-tree",
      "",
    }
    local filetype_str = ""

    if str == "toggleterm" then
      -- 
      filetype_str = "ToggleTerm " .. vim.api.nvim_buf_get_var(0, "toggle_number")
    elseif str == "TelescopePrompt" then
      filetype_str = ""
    elseif str == "neo-tree" or str == "neo-tree-popup" then
      if prev_filetype == "" then
        return
      end
      filetype_str = prev_filetype
    elseif str == "help" then
      filetype_str = ""
    elseif vim.tbl_contains(ui_filetypes, str) then
      return
    else
      prev_filetype = str
      filetype_str = str
    end
    local left_sep = hl_str(M.default.separator_icon.left, "SLSeparator")
    local right_sep = hl_str(M.default.separator_icon.right, "SLSeparator", "SLSeparator")
    -- Upper case first character
    filetype_str = filetype_str:gsub("%a", string.upper, 1)
    local filetype_hl = hl_str(filetype_str, "SLFiletype", "SLFiletype")
    return left_sep .. filetype_hl .. right_sep
  end,
}


return M
