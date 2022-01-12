local telescope = require("telescope")
local actions = require('telescope.actions')

local u = require("utils")

telescope.setup({
    config = {
        layout_strategy = 'flex',
        scroll_strategy = 'cycle',
        mappings = {i = {["<esc>"] = actions.close}},
        winblend = 0,
        layout_defaults = {
            horizontal = {
                width_padding = 0.1,
                height_padding = 0.1,
                preview_width = 0.6,
                -- mirror = false,
            },
            vertical = {
                width_padding = 0.05,
                height_padding = 1,
                preview_height = 0.5,
                -- mirror = true,
            },
        },
        file_ignore_patterns = {'tags'},
    },
})

telescope.load_extension('file_browser')

u.lua_command("Files", "global.telescope.find_files()")
u.command("Ag", "Telescope live_grep")
u.command("BLines", "Telescope current_buffer_fuzzy_find")
u.command("History", "Telescope oldfiles")
u.command("Buffers", "Telescope buffers")
u.command("BCommits", "Telescope git_bcommits")
u.command("Commits", "Telescope git_commits")
u.command("HelpTags", "Telescope help_tags")
u.command("ManPages", "Telescope man_pages")
u.command("FileBrowser", "Telescope file_browser")

u.map("n", "<Leader>ff", "<cmd>Files<CR>")
u.map("n", "<Leader>fb", "<cmd>FileBrowser<CR>")
u.map("n", "<Leader>fg", "<cmd>Ag<CR>")
u.map("n", "<Leader> ", "<cmd>Buffers<CR>")
u.map("n", "<Leader>fo", "<cmd>History<CR>")
u.map("n", "<Leader>fh", "<cmd>HelpTags<CR>")
u.map("n", "<Leader>fl", "<cmd>BLines<CR>")
u.map("n", "<Leader>fs", "<cmd>LspSym<CR>")

-- lsp
u.command("LspRef", "Telescope lsp_references")
u.command("LspDef", "Telescope lsp_definitions")
u.command("LspSym", "Telescope lsp_workspace_symbols")
u.command("LspAct", "Telescope lsp_code_actions")
