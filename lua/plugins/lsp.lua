return {
  "neovim/nvim-lspconfig",
  opts = {
    autoformat = true,
    servers = {
      vtsls = {
        capabilities = {
          textDocument = {
            completion = {
              completionItem = {
                snippetSupport = true,
              },
              -- Inject your path symbols directly into the server's native response schema
              completionProvider = {
                triggerCharacters = { ".", "/", '"', "'", "`", "@" },
              },
            },
          },
        },
        handlers = {
          ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
            if result and result.diagnostics then
              local filtered = {}
              for _, d in ipairs(result.diagnostics) do
                -- 6133: unused variable, 6196: unused declaration
                if d.code ~= 6133 and d.code ~= 6196 then
                  table.insert(filtered, d)
                end
              end
              result.diagnostics = filtered
            end
            vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
          end,
        },
        inlay_hints = {
          enabled = false,
        },
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
            preferences = {
              -- Options: "non-relative" (prefers alias), "relative", "shortest", or "project-relative"
              importModuleSpecifier = "non-relative",
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
            preferences = {
              -- Options: "non-relative" (prefers alias), "relative", "shortest", or "project-relative"
              importModuleSpecifier = "non-relative",
            },
          },
          vtsls = {
            autoCompleteFunctionCalls = false,
            autoOrganizeImports = false,
          },
        },
      },
      vue_ls = {
        capabilities = {
          textDocument = {
            completion = {
              completionProvider = {
                triggerCharacters = { ".", "/", '"', "'", "`", "@" },
              },
            },
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
        end
      end,
    },
  },
}
