-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<C-a>", "vag", { desc = "Select all file content", remap = true })
vim.keymap.set("v", "<C-a>", "ag", { desc = "Select all file content", remap = true })

vim.keymap.set("n", "<C-c>", "gcc", { desc = "Comment (out) current line", remap = true })
vim.keymap.set("v", "<C-c>", "gc", { desc = "Comment (out) selected lines", remap = true })

vim.keymap.set("n", "<M-L>", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer right" })
vim.keymap.set("n", "<M-H>", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer left" })
vim.keymap.set({ "n", "x" }, "gg", "gg0", { desc = "Go to first line and first symbol" })
vim.keymap.set({ "n", "x" }, "G", "G$", { desc = "Go to last line and last symbol" })

-- absolute path to clipboard
vim.keymap.set("n", "<F1>", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy absolute file path" })

-- relative path to clipboard (relative to cwd; equivalent to %:f in your snippet)
vim.keymap.set("n", "<F2>", function()
  vim.fn.setreg("+", vim.fn.expand("%:f"))
end, { desc = "Copy relative file path" })

-- filename to clipboard
vim.keymap.set("n", "<F3>", function()
  local name = vim.fn.expand("%:t")
  name = name:gsub("%..+$", "") -- remove everything after first dot
  vim.fn.setreg("+", name)
end, { desc = "Copy filename without any extension" })

vim.keymap.set("n", "<C-e>", ":Neotree toggle<CR>", { desc = "Neo-tree Toggle" })

-- Fix 'c' and 'C' to not copy to clipboard
vim.keymap.set({ "n", "v" }, "c", '"_c', { desc = "Change without yanking" })
vim.keymap.set({ "n", "v" }, "C", '"_C', { desc = "Change without yanking" })

vim.keymap.set({ "n", "v" }, "x", '"_x', { desc = "Delete character without yanking" })

local function duplicate_lines(direction)
  local mode = vim.api.nvim_get_mode().mode
  local cursor_line = vim.fn.line(".")
  local anchor_line = vim.fn.line("v")
  local target_column = vim.fn.col(".") -- Capture the exact 1-indexed column

  -- Determine the actual range for the command
  local range_start = math.min(anchor_line, cursor_line)
  local range_end = math.max(anchor_line, cursor_line)
  local count = range_end - range_start + 1

  -- Exit visual mode to "reset" the anchor
  if mode:find("[vV]") then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", true)
  end

  if direction == "down" then
    -- Duplicate the range below itself
    vim.cmd(string.format("%d,%dt%d", range_start, range_end, range_end))

    -- Calculate new positions for anchor and cursor
    local new_anchor = anchor_line + count
    local new_cursor = cursor_line + count

    if mode:find("[vV]") then
      -- Re-select from the new anchor to the new cursor position
      vim.api.nvim_win_set_cursor(0, { new_anchor, 0 })
      vim.cmd("normal! " .. mode)
      -- Use target_column - 1 for the 0-indexed API call
      vim.api.nvim_win_set_cursor(0, { new_cursor, target_column - 1 })
    else
      -- Normal mode: Just jump to the same column on the new line
      vim.api.nvim_win_set_cursor(0, { new_cursor, target_column - 1 })
    end
  else
    -- Duplicate Up: range is copied above the first line of the range
    vim.cmd(string.format("%d,%dt%d", range_start, range_end, range_start - 1))

    -- When duplicating up, the new lines occupy the original line numbers.
    -- We just need to re-select that same range.
    if mode:find("[vV]") then
      vim.api.nvim_win_set_cursor(0, { anchor_line, 0 })
      vim.cmd("normal! " .. mode)
      vim.api.nvim_win_set_cursor(0, { cursor_line, target_column - 1 })
    else
      vim.api.nvim_win_set_cursor(0, { cursor_line, target_column - 1 })
    end
  end
end

-- Duplicate Down
vim.keymap.set("n", "<M-J>", function()
  duplicate_lines("down")
end, { desc = "Duplicate Down" })
vim.keymap.set("v", "<M-J>", function()
  duplicate_lines("down")
end, { desc = "Duplicate Down" })

-- Duplicate Up
vim.keymap.set("n", "<M-K>", function()
  duplicate_lines("up")
end, { desc = "Duplicate Up" })
vim.keymap.set("v", "<M-K>", function()
  duplicate_lines("up")
end, { desc = "Duplicate Up" })

vim.keymap.set("n", "J", "<Nop>", { desc = "Disable built-in line join" })

-- Override default LazyVim behavior to search in CWD instead of Project Root
vim.keymap.set("n", "<leader><space>", LazyVim.pick("files", { root = false }), { desc = "Find Files (cwd)" })

-- Optional: Do the same for your global text search (grep)
vim.keymap.set("n", "<leader>/", LazyVim.pick("live_grep", { root = false }), { desc = "Grep (cwd)" })
