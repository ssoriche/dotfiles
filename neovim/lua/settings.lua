local o = vim.o -- Global options
local wo = vim.wo -- Window options
local bo = vim.bo -- Buffer options

local indent = 2

-- Buffer
bo.expandtab = true -- Use spaces instead of tabs
bo.shiftwidth = indent -- Size of an indent
bo.smartindent = true -- Insert indents automatically
bo.tabstop = indent -- Number of spaces tabs count for

-- Global
o.completeopt = 'menuone,noinsert,noselect' -- Completion options (for deoplete)
o.hidden = true -- Enable modified buffers in background
o.ignorecase = true -- Ignore case
o.joinspaces = false -- No double spaces with join after a dot
o.scrolloff = 4 -- Lines of context
o.shiftround = true -- Round indent
o.sidescrolloff = 8 -- Columns of context
o.smartcase = true -- Don't ignore case with capitals
o.splitbelow = true -- Put new windows below current
o.splitright = true -- Put new windows right of current
o.termguicolors = true -- True color support
o.wildmode = 'list:longest' -- Command-line completion mode

-- Window
wo.number = true -- Print line number
wo.relativenumber = true -- Relative line numbers
wo.wrap = false -- Disable line wrap
