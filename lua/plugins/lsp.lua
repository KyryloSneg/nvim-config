return {
  "neovim/nvim-lspconfig",
  opts = {
    autoformat = true,
    servers = {
      vtsls = {
        settings = {
          typescript = {
            format = {
              enable = false,
              indentSize = 2, -- Tell the LSP to use 2 spaces
              tabSize = 2, -- Match your options.lua
            },
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = false,
            },
          },
          javascript = {
            format = {
              enable = false,
              indentSize = 2, -- Tell the LSP to use 2 spaces
              tabSize = 2, -- Match your options.lua
            },
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              -- And for JS
              completeFunctionCalls = false,
            },
          },
          vtsls = {
            autoCompleteFunctionCalls = false,
            autoOrganizeImports = false,
          },
        },
      },
    },
    setup = {
      vtsls = function(_, opts)
        opts.on_attach = function(client, buffer)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false

          opts.settings = opts.settings or {}
          opts.settings.typescript = opts.settings.typescript or {}
          opts.settings.typescript.suggest = opts.settings.typescript.suggest or {}
          -- Disable complete functions with parenthesis
          opts.settings.typescript.suggest.completeFunctionCalls = false

          -- Ensure "/" and "@" are in the trigger list instead of clearing it
          if client.server_capabilities.completionProvider then
            local triggers = client.server_capabilities.completionProvider.triggerCharacters or {}
            if not vim.tbl_contains(triggers, "/") then
              table.insert(triggers, "/")
            end
            if not vim.tbl_contains(triggers, "@") then
              table.insert(triggers, "@")
            end
            client.server_capabilities.completionProvider.triggerCharacters = triggers
          end
        end
      end,
      vue_ls = function(_, opts)
        opts.on_attach = function(client)
          if client.server_capabilities.completionProvider then
            local triggers = client.server_capabilities.completionProvider.triggerCharacters or {}
            if not vim.tbl_contains(triggers, "/") then
              table.insert(triggers, "/")
            end
            client.server_capabilities.completionProvider.triggerCharacters = triggers
          end
        end
      end,
    },
  },
}
