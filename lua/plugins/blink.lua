local get_filename_and_ext = function(item)
  local raw_text = ""

  if item.detail then
    raw_text = item.detail
  elseif item.textEdit and item.textEdit.newText then
    raw_text = item.textEdit.newText
  else
    raw_text = item.detail or item.insertText or item.label or ""
  end

  raw_text = raw_text:gsub("%$%d", ""):gsub("%$0", "")

  local name, ext = raw_text:match("^([^.]+)(%.+([^.]*))$")
  if not name then
    name = raw_text
    ext = ""
  end

  -- Strip leading dots from extension for uniform indexing
  if ext:sub(1, 1) == "." then
    ext = ext:sub(2)
  end

  return name, ext
end

local get_mini_icon = function(ctx)
  local mini_icons = package.loaded["mini.icons"]

  if not mini_icons then
    return "  ", "MiniIconsFile"
  end

  if ctx.kind == "File" or ctx.kind == "Folder" then
    local name, ext = get_filename_and_ext(ctx.item)
    local lookup_name = name

    -- If we stripped the extension earlier, re-append it for mini.icons evaluation
    if ext and ext ~= "" then
      lookup_name = lookup_name .. "." .. ext
    end

    local category = ctx.kind == "Folder" and "directory" or "file"
    local icon, hl = mini_icons.get(category, lookup_name)

    -- Fallback safety for completely extensionless files if mini.icons returns nil
    if not icon then
      icon, hl = mini_icons.get("file", "default")
    end

    return icon or "  ", hl or "MiniIconsFile"
  end

  return mini_icons.get("lsp", ctx.kind)
end

return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        path = {
          name = "Path",
          module = "blink.cmp.sources.path",
          score_offset = 10,
          opts = {
            -- This logic fixes the "pollution" issue:
            get_cwd = function(context)
              -- If you type "/", search from project root
              -- If you type "./", search from the current file's directory
              local path_prefix = context.line:sub(1, context.cursor[2])
              if path_prefix:match("['\"]/$") then
                return vim.fn.getcwd()
              end

              return vim.fn.expand("%:p:h")
            end,
            show_hidden_files_by_default = false,
          },
          -- This ensures it triggers on "/" immediately
          min_keyword_length = 0,
          --- @param items blink.cmp.CompletionItem[]
          transform_items = function(_, items)
            local filtered_items = vim.tbl_filter(function(item)
              -- Remove items that end exactly with '.ts' and '.js'
              return not (string.match(item.label, "%.js$") or string.match(item.label, "%.ts$"))
            end, items)

            return filtered_items
          end,
        },
        snippets = {
          score_offset = -1,
          min_keyword_length = 3,
          enabled = function()
            local col = vim.fn.col(".")
            local line = vim.fn.getline(".")
            return not line:sub(2, col):match("[\"']")
          end,
        },
      },
    },
    completion = {
      accept = {
        -- Set this to false to stop auto-inserting parentheses
        auto_brackets = { enabled = false },
      },
      ghost_text = { enabled = false },
      menu = {
        auto_show = true,
        draw = {
          -- Define the structure: Icon first, then the label
          columns = { { "kind_icon" }, { "label", "label_description", gap = 2 } },
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                local icon, _ = get_mini_icon(ctx)
                return icon .. " " -- Add a little space after the icon
              end,
              highlight = function(ctx)
                local _, hl = get_mini_icon(ctx)
                return hl
              end,
            },
          },
        },
      },
      trigger = {
        show_on_trigger_character = true,
        show_on_blocked_trigger_characters = { "/", ".", "@" },
      },
    },
  },
}
