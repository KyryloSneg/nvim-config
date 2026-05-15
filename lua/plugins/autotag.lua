-- /plugins/autotag.lua
return {
  {
    "windwp/nvim-ts-autotag",
    -- Ensure the plugin loads when you start typing in a file
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- This 'opts' table is passed as the argument to the plugin's setup()
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true, -- This handles the <span / -> <span /> transition
      },
    },
  },
}
