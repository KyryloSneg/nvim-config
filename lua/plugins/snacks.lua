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
          },
        },
      },
    },
  },
}
