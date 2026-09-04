return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local dotnet = require("easy-dotnet")
      dotnet.setup()

      vim.keymap.set("n", "<leader>dr", function()
        dotnet.run()
      end, { desc = "Dotnet Run Project" })
      vim.keymap.set("n", "<leader>db", function()
        dotnet.build()
      end, { desc = "Dotnet Build Project" })
      vim.keymap.set("n", "<leader>dt", function()
        dotnet.test()
      end, { desc = "Dotnet Run Tests" })
    end,
  },
}
