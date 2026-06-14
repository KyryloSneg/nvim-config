return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      typescript = { "organize_imports", "prettier" },
      javascript = { "organize_imports", "prettier" },
      typescriptreact = { "organize_imports", "prettier" },
      javascriptreact = { "organize_imports", "prettier" },
      vue = { "organize_imports", "prettier" },
      prisma = { "prisma_format" },
    },
    formatters = {
      prisma_format = {
        -- prisma format needs to write/read temp files instead of standard input
        stdin = false,
      },
    },
  },
}
