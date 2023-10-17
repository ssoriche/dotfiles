local M = {
  "neovim/nvim-lspconfig",
  event = "BufReadPre",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
    {
      "folke/neodev.nvim",
      opts = {
        debug = true,
        experimental = {
          pathStrict = true,
        },
        --        library = {
        --          runtime = "~/projects/neovim/runtime/",
        --        },
      },
    },
    "mason.nvim",
    "williamboman/mason-lspconfig.nvim"
  },
  --  pin = true,
}

function M.config()
  require("mason")
  require("plugins.lsp.diagnostics").setup()

  local function on_attach(client, bufnr)
    require("nvim-navic").attach(client, bufnr)
    require("plugins.lsp.formatting").setup(client, bufnr)
    require("plugins.lsp.keys").setup(client, bufnr)
  end

  ---@type lspconfig.options
  local servers = {
    ansiblels = {},
    bashls = {},
    clangd = {},
    cssls = {},
    dockerls = {},
    tsserver = {},
    svelte = {},
    eslint = {},
    html = {},
    jsonls = {
      settings = {
        json = {
          format = {
            enable = true,
          },
          schemas = require("schemastore").json.schemas(),
          validate = { enable = true },
        },
      },
    },
    gopls = {},
    marksman = {},
    pyright = {},
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = {
            command = "clippy",
            extraArgs = { "--no-deps" },
          },
        },
      },
    },
    yamlls = {},
    lua_ls = {
      settings = {
        Lua = {
          workspace = {
            checkThirdParty = false,
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    },
    terraformls = {},
    teal_ls = {},
    vimls = {},
    -- tailwindcss = {},
  }

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }

  ---@type _.lspconfig.options
  local options = {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = {
      debounce_text_changes = 150,
    },
  }

  for server, opts in pairs(servers) do
    opts = vim.tbl_deep_extend("force", {}, options, opts or {})
    require("lspconfig")[server].setup(opts)
  end

  require("plugins.none-ls").setup(options)
end

return M
