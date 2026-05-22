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

-- Функция-помощник для проверки, является ли строка импортом
local function is_import_line(ctx)
  -- 1. Получаем точный текст текущей строки из API Neovim
  local line = vim.api.nvim_get_current_line()

  -- 2. Проверяем, содержит ли строка синтаксис импорта (JS/TS/Vue)
  -- Ищет "import ", "{ ... }", кавычки или "from"
  if line:match("import%s") or line:match("from%s+['\"]") or line:match("['\"]") then
    return true
  end

  -- 3. Дополнительная проверка через встроенный контекст курсора blink
  if ctx and ctx.line and (ctx.line:match("import") or ctx.line:match("from")) then
    return true
  end

  return false
end

local function get_extensionless_base(label)
  local lower_label = label:lower()

  if string.match(lower_label, "%.jsx?$") or string.match(lower_label, "%.tsx?$") then
    return lower_label:gsub("%.jsx?$", ""):gsub("%.tsx?$", "")
  end

  return nil
end

local function log_to_messages(msg, data)
  local str = tostring(msg)
  if data ~= nil then
    if type(data) == "table" then
      str = str .. " " .. vim.inspect(data)
    else
      str = str .. " (" .. type(data) .. "): " .. tostring(data)
    end
  end
  -- This forces logs directly into the :messages history buffer bypassing toast popups
  vim.api.nvim_echo({ { str, "Normal" } }, true, {})
end

local transform_paths_and_lsp = function(ctx, items)
  local win_sys_blacklist = {
    ["program files"] = true,
    ["program files (x86)"] = true,
    ["programdata"] = true,
    ["recovery"] = true,
    ["perflogs"] = true,
    ["system volume information"] = true,
    ["users"] = true,
    ["windows"] = true,
    ["appdata"] = true,
    ["$recycle.bin"] = true,
    ["$winreagent"] = true,
    ["$windows.~bt"] = true,
    ["$windows.~ws"] = true,
    ["boot"] = true,
    ["documents and settings"] = true,
    ["intel"] = true,
    ["amd"] = true,
    ["msocache"] = true,
    ["config.msi"] = true,
    ["games"] = true,
    ["wamp"] = true,
    ["xampp"] = true,
    ["zig"] = true,
    ["tmp"] = true,
    ["inetpub"] = true,
  }

  -- 1. Detect Project Context from Current Buffer Path
  local current_file = vim.api.nvim_buf_get_name(ctx.bufnr or 0):gsub("\\", "/")

  -- Define your rules here: true = keep extensions, false = keep extensionless
  -- Works for both monorepo folders (/server/) and standalone root projects (/my-backend-api/)
  local project_rules = {
    ["/server/"] = true,
    ["/shared/"] = true,
    -- Add more project paths or names as needed
  }

  local require_extensions = false
  for pattern, needs_ext in pairs(project_rules) do
    if string.find(current_file:lower(), pattern:lower(), 1, true) then
      require_extensions = needs_ext
      break
    end
  end

  local filtered_items = vim.tbl_filter(function(item)
    local is_folder = item.kind == 19
    local is_file = item.kind == 17

    -- 2. CRITICAL GUARD: If it's a variable, function, or auto-import action,
    -- let it pass through completely untouched.
    if not is_folder and not is_file then
      return true
    end

    local label = item.label
    local lower_label = label:lower():gsub("/$", "")

    -- A. Context-Aware Extension Filtering
    local filename, ext = get_filename_and_ext(item)
    local lower_ext = ext and ext:lower() or ""

    if is_folder then
      if lower_label == "node_modules" or lower_label == "node_modules/" then
        return false
      end
    else
      local clean_label = lower_label:gsub("/$", "")

      if require_extensions then
        if filename and ext then
          local filename_with_ext = filename .. "." .. ext

          if not (label == filename_with_ext) then
            item.label = filename_with_ext

            -- Normalize basic inserts
            if item.insertText then
              item.insertText = filename_with_ext
            end

            -- Normalize LSP specific inserts (Crucial for Volar/TS Server)
            if item.textEdit and item.textEdit.newText then
              item.textEdit.newText = filename_with_ext
            end

            label = item.label
            lower_label = label:lower():gsub("/$", "")
          end
        end
      else
        -- Your original behavior: Filter out exact module file match extensions (.ts and .js)
        if get_extensionless_base(clean_label) then
          return false
        end
      end
    end

    if lower_ext == "json" or string.match(lower_label, "%.json$") then
      return false
    end

    -- B. Evaluate System Junk Criteria
    local is_sys_file = lower_ext == "sys"
      or lower_ext == "dll"
      or lower_ext == "exe"
      or lower_ext == "lnk"
      or lower_ext == "log"
      or lower_ext == "tmp"
      or lower_ext == "log.tmp"
      or win_sys_blacklist[lower_label]
      or lower_label:match("^ntuser")
      or lower_label:match("^boot")
      or string.match(lower_label, "%.log%.tmp$")

    if is_sys_file then
      return false
    end

    -- C. Fix Folder Autocomplete Duplication (Both LSP and Path)
    local lacks_trailing_slash = not string.match(label, "/$")

    if is_folder and lacks_trailing_slash then
      -- Normalize the visible label
      item.label = label .. "/"

      -- Normalize basic inserts
      if item.insertText then
        item.insertText = item.insertText .. "/"
      end

      -- Normalize LSP specific inserts (Crucial for Volar/TS Server)
      if item.textEdit and item.textEdit.newText then
        item.textEdit.newText = item.textEdit.newText .. "/"
      end

      -- MUST RETURN TRUE to keep the item in the list!
      return true
    end

    return true
  end, items)

  return filtered_items
end

return {
  "saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "snippets", "buffer" },

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
          transform_items = function()
            return {}
          end,
        },
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",
          min_keyword_length = 0,
          transform_items = transform_paths_and_lsp,
        },
        snippets = {
          score_offset = -1,
          min_keyword_length = 3,
          should_show_items = function(ctx)
            return not is_import_line(ctx)
          end,
        },
        -- 2. Фильтруем случайные слова из текущего файла (буфера)
        buffer = {
          score_offset = -1,
          should_show_items = function(ctx)
            return not is_import_line(ctx)
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

        -- Enable triggers when typing defined LSP trigger characters (like quotes or slashes)
        show_on_trigger_character = true,

        -- Ensure it triggers immediately when entering insert mode or typing a trigger
        show_on_insert_on_trigger_character = true,

        -- RESET THIS: Only block completion when typing after empty whitespace
        show_on_blocked_trigger_characters = { " ", "\n", "\t" },
      },
    },
  },
}
