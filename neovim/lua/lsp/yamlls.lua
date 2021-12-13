local lspconfig = require("lspconfig")

local M = {}

local function getlines(i, j)
    return table.concat(vim.api.nvim_buf_get_lines(0, i - 1, j or i, true), "\n")
end

local function newconfig(new_config, new_root_dir)
    if getlines(1, 2):find("apiVersion:") then
        local kind = getlines(2, 3)
        local glob = "/*" + vim.api.nvim_buf_get_name(0)
        if kind:find("kind: Deployment") then
            new_config.settings.yaml.schemas = {
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0/deployment.json"] = glob,
            }
        elseif kind:find("kind: Service") then
            new_config.settings.yaml.schemas = {
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0/service.json"] = glob,
            }
        elseif kind:find("kind: NetworkPolicy") then
            new_config.settings.yaml.schemas = {
                ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0/networkpolicy.json"] = glob,
            }
        elseif kind:find("kind: Prometheus") then
            new_config.settings.yaml.schemas = {
                ["http://json.schemastore.org/prometheus"] = glob,
            }
        end
    end
    print(vim.inspect(new_config.settings.yaml.schemas))
end

M.setup = function(on_attach, capabilities)
    local yaml_schemas = {}
    if getlines(1, 2):find("apiVersion:") then
        vim.opt.filetype = "yaml.k8s"
        yaml_schemas = {
            ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.22.0/all.json"] = "/*",
        }
    end
    -- https://github.com/redhat-developer/yaml-language-server
    lspconfig.yamlls.setup({
        on_attach = on_attach,
        on_new_config = newconfig,
        settings = {
            yaml = { schemas = yaml_schemas },
        },
        capabilities = capabilities,
    })
end

return M
