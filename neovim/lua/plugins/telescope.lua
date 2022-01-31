local telescope = require("telescope")
local actions = require("telescope.actions")

local u = require("utils")

telescope.setup({
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
    config = {
        mappings = { i = { ["<esc>"] = actions.close } },
        file_ignore_patterns = { "tags" },
    },
    defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
            },
            vertical = {
                mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
        },
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = true,
    },
})

telescope.load_extension("file_browser")
telescope.load_extension("fzf")

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
