local lspconfig = require("lspconfig")

local M = {}

local function getlines(i, j)
    return table.concat(vim.api.nvim_buf_get_lines(0, i - 1, j or i, true), "\n")
end

local function newconfig(new_config, new_root_dir)
    if getlines(1, 3):find("apiVersion:") then
        local kind = getlines(1, 3)
        local glob = "/*" .. vim.api.nvim_buf_get_name(0)

        local start, finish = kind:find("kind:")
        if start then
            local name = string.sub(kind, finish + 1, string.len(kind))
            local _, newline = name:find("\n")
            name = string.sub(name, 0, newline)
            name = name:gsub("%s+", "")
            name = name:lower()
            new_config.settings.yaml.schemas = {
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0/" .. name .. ".json"] = glob,
            }
        end
        if kind:find("kind: Prometheus") then
            new_config.settings.yaml.schemas = {
                ["http://json.schemastore.org/prometheus"] = glob,
            }
        end
    end
end

M.setup = function(on_attach, capabilities)
    local companion = require("yaml-companion").setup({
        lspconfig = {
            on_attach = on_attach,
            capabilities = capabilities,
        },
    })
    lspconfig.yamlls.setup(companion)
end

return M
