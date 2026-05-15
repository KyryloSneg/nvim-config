return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      picker = {
        sources = {
          explorer = {
            -- Эти настройки заставляют проводник вести себя как постоянный сайдбар
            layout = {
              position = "left", -- Положение окна (слева)
              width = 30, -- Фиксированная ширина
            },
            -- Если хотите, чтобы он не закрывался автоматически при выборе файла
            jump = { close = false },
            -- Автоматически открывать при старте (опционально)
            auto_open = true,
            -- win = {
            --   list = {
            --     keys = {
            --       ["<C-y>"] = {
            --         action = function(picker)
            --           local item = picker:current()
            --           if item then
            --             -- fnamemodify(..., ":t:r") gets the filename (t) and removes extension (r)
            --             local name = vim.fn.fnamemodify(item.file or item.text, ":t:r")
            --             vim.fn.setreg("+", name)
            --             vim.notify("Copied: " .. name)
            --           end
            --         end,
            --         mode = { "n", "i" },
            --         desc = "Copy filename without extension",
            --       },
            --     },
            --   },
            -- },
          },
        },
      },
    },
  },
}
