-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("SwapExists", {
  callback = function()
    vim.v.swapchoice = "e" -- "e" stands for (E)dit anyway
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescriptreact", "javascriptreact", "vue", "html" },
  callback = function()
    vim.keymap.set("i", " /", " />", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("TextChangedI", {
  desc = "Force blink.cmp to trigger path completions on '/' or '@' inside strings",
  pattern = "*",
  callback = function()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if col == 0 then
      return
    end

    local line = vim.api.nvim_get_current_line()
    local char = string.sub(line, col, col)

    if char == "/" or char == "@" then
      -- Get the entire line up to where your cursor currently is
      local line_to_cursor = string.sub(line, 1, col)

      -- Count quotes before the cursor to see if we are inside a string literal
      local _, quotes_double = line_to_cursor:gsub('"', "")
      local _, quotes_single = line_to_cursor:gsub("'", "")
      local _, quotes_backtick = line_to_cursor:gsub("`", "")

      -- If any quote type has an odd count, the cursor is inside an active string
      local is_string = (quotes_double % 2 == 1) or (quotes_single % 2 == 1) or (quotes_backtick % 2 == 1)

      -- Force blink to show the completion menu if we're in a string context
      if is_string then
        pcall(function()
          require("blink.cmp").show()
        end)
      end
    end
  end,
})
