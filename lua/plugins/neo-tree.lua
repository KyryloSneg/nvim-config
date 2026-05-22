return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      find_by_full_path_words = true,
      group_empty_dirs = true,
      search_limit = 50,

      find_command = "fd",
      find_args = {
        fd = {
          "--exclude",
          "node_modules",
          "--exclude",
          ".git",
        },
      },

      follow_current_file = {
        enabled = true, -- This enables the feature
        leave_dirs_open = false, -- Closes other directories when switching files
      },

      filtered_items = {
        visible = true, -- Show filtered items in a different highlight group
        hide_dotfiles = false, -- Do not hide files starting with a dot
        hide_gitignored = false, -- Do not hide files listed in .gitignore
        hide_hidden = false, -- Do not hide hidden files (relevant on Windows/macOS)
        hide_ignored = false,
        hide_by_name = {}, -- Clear any default name filters
        hide_by_pattern = {}, -- Clear any default pattern filters
        always_show = { -- Explicitly force these to show up
          ".gitignore",
          ".git",
          ".env",
          ".vscode",
        },
        never_show = { -- Only keep things you truly never want to see
          ".DS_Store",
          "thumbs.db",
        },
        never_show_by_pattern = {
          "node_modules/*",
        },
      },
    },
  },
}
