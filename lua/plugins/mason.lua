return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    opts.ensure_installed = vim.tbl_filter(function(item)
      return item ~= "tree-sitter-cli"
    end, opts.ensure_installed)
  end,
}
