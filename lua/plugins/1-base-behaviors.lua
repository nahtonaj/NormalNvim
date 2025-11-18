-- Core behaviors
-- Plugins that add new behaviors.

--    Sections:
--       -> yazi file browser      [yazi]
--       -> project.nvim           [project search + auto cd]
--       -> trim.nvim              [auto trim spaces]
--       -> stickybuf.nvim         [lock special buffers]
--       -> mini.bufremove         [smart bufdelete]
--       -> smart-splits           [move and resize buffers]
--       -> toggleterm.nvim        [term]
--       -> session-manager        [session]
--       -> spectre.nvim           [search and replace in project]
--       -> neotree file browser   [neotree]
--       -> nvim-ufo               [folding mod]
--       -> nvim-neoclip           [nvim clipboard]
--       -> zen-mode.nvim          [distraction free mode]
--       -> suda.vim               [write as sudo]
--       -> vim-matchup            [Improved % motion]
--       -> hop.nvim               [go to word visually]
--       -> nvim-autopairs         [auto close brackets]
--       -> nvim-ts-autotag        [auto close html tags]
--       -> lsp_signature.nvim     [auto params help]
--       -> nvim-lightbulb         [lightbulb for code actions]
--       -> hot-reload.nvim        [config reload]
--       -> distroupdate.nvim      [distro update]

local is_android = vim.fn.isdirectory('/data') == 1 -- true if on android

local insert_mode_onshow = {
  on_show = function()
    vim.cmd.startinsert()
  end,
}

return {

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        ---@type snacks.dashboard.Item[]
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Yazi", action = ":Yazi" },
            { icon = " ", key = "R", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
            pane = 2,
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "git status --short --branch --renames",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = "startup" },
        },
      },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      picker = {
        layout = {
          -- preview = "main",
          preset = "ivy"
        },
        matcher = {
          fuzzy = true,
          frecency = true,
          filename_bonus = true
        },
        on_show = function ()
          vim.cmd.stopinsert()
        end,
        enabled = true
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true } -- Wrap notifications
        }
      }
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart(insert_mode_onshow) end,                                   desc = "Smart Find Files" },
      { "<leader>,",       function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      { "<leader>/",       function() Snacks.picker.grep(insert_mode_onshow) end,                                    desc = "Grep" },
      { "<leader>:",       function() Snacks.picker.command_history() end,                         desc = "Command History" },
      { "<leader>n",       function() Snacks.picker.notifications() end,                           desc = "Notification History" },
      { "<leader>e",       function() Snacks.explorer() end,                                       desc = "File Explorer" },
      -- find
      { "<leader>fb",      function() Snacks.picker.buffers() end,                                 desc = "Buffers" },
      { "<leader>fc",      function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff",      function() Snacks.picker.files(insert_mode_onshow) end,                                   desc = "Find Files" },
      { "<leader>fg",      function() Snacks.picker.git_files() end,                               desc = "Find Git Files" },
      { "<leader>fp",      function() Snacks.picker.projects() end,                                desc = "Projects" },
      { "<leader>fr",      function() Snacks.picker.recent() end,                                  desc = "Recent" },
      -- git
      { "<leader>gb",      function() Snacks.picker.git_branches() end,                            desc = "Git Branches" },
      { "<leader>gl",      function() Snacks.picker.git_log() end,                                 desc = "Git Log" },
      { "<leader>gL",      function() Snacks.picker.git_log_line() end,                            desc = "Git Log Line" },
      { "<leader>gs",      function() Snacks.picker.git_status() end,                              desc = "Git Status" },
      { "<leader>gS",      function() Snacks.picker.git_stash() end,                               desc = "Git Stash" },
      { "<leader>gd",      function() Snacks.picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
      { "<leader>gf",      function() Snacks.picker.git_log_file() end,                            desc = "Git Log File" },
      -- Grep
      { "<leader>sb",      function() Snacks.picker.lines() end,                                   desc = "Buffer Lines" },
      { "<leader>sB",      function() Snacks.picker.grep_buffers(insert_mode_onshow) end,                            desc = "Grep Open Buffers" },
      { "<leader>sg",      function() Snacks.picker.grep(insert_mode_onshow) end,                                    desc = "Grep" },
      { "<leader>sw",      function() Snacks.picker.grep_word(insert_mode_onshow) end,                               desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s"',      function() Snacks.picker.registers() end,                               desc = "Registers" },
      { '<leader>s/',      function() Snacks.picker.search_history() end,                          desc = "Search History" },
      { "<leader>sa",      function() Snacks.picker.autocmds() end,                                desc = "Autocmds" },
      { "<leader>sb",      function() Snacks.picker.lines(insert_mode_onshow) end,                                   desc = "Buffer Lines" },
      { "<leader>sc",      function() Snacks.picker.command_history() end,                         desc = "Command History" },
      { "<leader>sC",      function() Snacks.picker.commands() end,                                desc = "Commands" },
      { "<leader>sd",      function() Snacks.picker.diagnostics() end,                             desc = "Diagnostics" },
      { "<leader>sD",      function() Snacks.picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
      { "<leader>sh",      function() Snacks.picker.help() end,                                    desc = "Help Pages" },
      { "<leader>sH",      function() Snacks.picker.highlights() end,                              desc = "Highlights" },
      { "<leader>si",      function() Snacks.picker.icons() end,                                   desc = "Icons" },
      { "<leader>sj",      function() Snacks.picker.jumps() end,                                   desc = "Jumps" },
      { "<leader>sk",      function() Snacks.picker.keymaps() end,                                 desc = "Keymaps" },
      { "<leader>sl",      function() Snacks.picker.loclist() end,                                 desc = "Location List" },
      { "<leader>sm",      function() Snacks.picker.marks() end,                                   desc = "Marks" },
      { "<leader>sn",      function() Snacks.notifier.show_history() end,                          desc = "Notifications" },
      { "<leader>sM",      function() Snacks.picker.man() end,                                     desc = "Man Pages" },
      { "<leader>sp",      function() Snacks.picker.lazy() end,                                    desc = "Search for Plugin Spec" },
      { "<leader>sq",      function() Snacks.picker.qflist() end,                                  desc = "Quickfix List" },
      { "<leader>sR",      function() Snacks.picker.resume() end,                                  desc = "Resume" },
      { "<leader>su",      function() Snacks.picker.undo() end,                                    desc = "Undo History" },
      { "<leader>uC",      function() Snacks.picker.colorschemes() end,                            desc = "Colorschemes" },
      -- LSP
      { "gd",              function() Snacks.picker.lsp_definitions() end,                         desc = "Goto Definition" },
      { "gD",              function() Snacks.picker.lsp_declarations() end,                        desc = "Goto Declaration" },
      { "gr",              function() Snacks.picker.lsp_references() end,                          nowait = true,                     desc = "References" },
      { "gI",              function() Snacks.picker.lsp_implementations() end,                     desc = "Goto Implementation" },
      { "gy",              function() Snacks.picker.lsp_type_definitions() end,                    desc = "Goto T[y]pe Definition" },
      { "<leader>ss",      function() Snacks.picker.lsp_symbols() end,                             desc = "LSP Symbols" },
      { "<leader>sS",      function() Snacks.picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },
      -- Other
      { "<leader>z",       function() Snacks.zen() end,                                            desc = "Toggle Zen Mode" },
      { "<leader>Z",       function() Snacks.zen.zoom() end,                                       desc = "Toggle Zoom" },
      { "<leader>.",       function() Snacks.scratch() end,                                        desc = "Toggle Scratch Buffer" },
      { "<leader>S",       function() Snacks.scratch.select() end,                                 desc = "Select Scratch Buffer" },
      { "<leader>bd",      function() Snacks.bufdelete() end,                                      desc = "Delete Buffer" },
      { "<leader>cR",      function() Snacks.rename.rename_file() end,                             desc = "Rename File" },
      -- { "<leader>gB",      function() Snacks.gitbrowse() end,                                      desc = "Git Browse",               mode = { "n", "v" } },
      { "<leader>gg",      function() Snacks.lazygit() end,                                        desc = "Lazygit" },
      { "<leader>un",      function() Snacks.notifier.hide() end,                                  desc = "Dismiss All Notifications" },
      { "<c-/>",           function() Snacks.terminal() end,                                       desc = "Toggle Terminal" },
      { "<c-_>",           function() Snacks.terminal() end,                                       desc = "which_key_ignore" },
      { "]]",              function() Snacks.words.jump(vim.v.count1) end,                         desc = "Next Reference",           mode = { "n", "t" } },
      { "[[",              function() Snacks.words.jump(-vim.v.count1) end,                        desc = "Prev Reference",           mode = { "n", "t" } },
      {
        "<leader>N",
        desc = "Neovim News",
        function()
          Snacks.win({
            file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "yes",
              statuscolumn = " ",
              conceallevel = 3,
            },
          })
        end,
      }
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map(
          "<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        end,
      })
    end,
  },

  -- [yazi] file browser
  -- https://github.com/mikavilpas/yazi.nvim
  -- Make sure you have yazi installed on your system!
  {
    "mikavilpas/yazi.nvim",
    event = "User BaseDefered",
    cmd = { "Yazi", "Yazi cwd", "Yazi toggle" },
    opts = {
        open_for_directories = true,
        floating_window_scaling_factor = (is_android and 1.0) or 0.71
    },
  },

  -- project.nvim [project search + auto cd]
  -- https://github.com/ahmedkhalf/project.nvim
  {
    "zeioth/project.nvim",
    event = "User BaseDefered",
    cmd = "ProjectRoot",
    opts = {
      -- How to find root directory
      patterns = {
        "Config",
        "packageInfo",
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        ".solution",
        ".solution.toml",
      },
      -- Don't list the next projects
      exclude_dirs = {
        "~/"
      },
      silent_chdir = true,
      manual_mode = false,

      -- Don't chdir for certain buffers
      exclude_chdir = {
        filetype = {"", "OverseerList", "alpha"},
        buftype = {"nofile", "terminal"},
      },

      --ignore_lsp = { "lua_ls" },
    },
    config = function(_, opts) require("project_nvim").setup(opts) end,
  },

  -- trim.nvim [auto trim spaces]
  -- https://github.com/cappyzawa/trim.nvim
  {
    "cappyzawa/trim.nvim",
    event = "BufWrite",
    opts = {
      trim_on_write = false,
      trim_trailing = false,
      trim_last_line = false,
      trim_first_line = false,
      -- ft_blocklist = { "markdown", "text", "org", "tex", "asciidoc", "rst" },
      -- patterns = {[[%s/\(\n\n\)\n\+/\1/]]}, -- Only one consecutive bl
    },
  },

  -- stickybuf.nvim [lock special buffers]
  -- https://github.com/arnamak/stay-centered.nvim
  -- By default it support neovim/aerial and others.
  {
    "stevearc/stickybuf.nvim",
    event = "User BaseDefered",
    config = function() require("stickybuf").setup() end
  },

  -- mini.bufremove [smart bufdelete]
  -- https://github.com/nvim-mini/mini.bufremove
  -- Defines what tab to go on :bufdelete
  {
    "nvim-mini/mini.bufremove",
    event = "User BaseFile"
  },

  --  smart-splits [move and resize buffers]
  --  https://github.com/mrjones2014/smart-splits.nvim
  {
    "mrjones2014/smart-splits.nvim",
    event = "User BaseFile",
    opts = {
      ignored_filetypes = { "nofile", "quickfix", "qf", "prompt" },
      ignored_buftypes = { "nofile" },
    },
  },

  -- Toggle floating terminal on <F7> [term]
  -- https://github.com/akinsho/toggleterm.nvim
  -- neovim bug → https://github.com/neovim/neovim/issues/21106
  -- workarounds → https://github.com/akinsho/toggleterm.nvim/wiki/Mouse-support
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    opts = {
      highlights = {
        Normal = { link = "Normal" },
        NormalNC = { link = "NormalNC" },
        NormalFloat = { link = "Normal" },
        FloatBorder = { link = "FloatBorder" },
        StatusLine = { link = "StatusLine" },
        StatusLineNC = { link = "StatusLineNC" },
        WinBar = { link = "WinBar" },
        WinBarNC = { link = "WinBarNC" },
      },
      size = 10,
      open_mapping = [[<F7>]],
      shading_factor = 2,
      direction = "float",
      float_opts = {
        border = "rounded",
        highlights = { border = "Normal", background = "Normal" },
      },
    },
  },

  -- session-manager [session]
  -- https://github.com/Shatur/neovim-session-manager
  {
    "Shatur/neovim-session-manager",
    event = "User BaseDefered",
    cmd = "SessionManager",
    opts = function()
      local config = require('session_manager.config')
      return {
        autoload_mode = config.AutoloadMode.CurrentDir,
        autosave_last_session = true,
        autosave_only_in_session = false,
      }
    end,
    config = function(_, opts)
      local session_manager = require('session_manager')
      session_manager.setup(opts)

      -- Auto save session
      -- BUG: This feature will auto-close anything nofile before saving.
      --      This include neotree, aerial, mergetool, among others.
      --      Consider commenting the next block if this is important for you.
      --
      --      This won't be necessary once neovim fixes:
      --      https://github.com/neovim/neovim/issues/12242
      -- vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
      --   callback = function ()
      --     session_manager.save_current_session()
      --   end
      -- })
    end
  },

  -- spectre.nvim [search and replace in project]
  -- https://github.com/nvim-pack/nvim-spectre
  -- INSTRUCTIONS:
  -- To see the instructions press '?'
  -- To start the search press <ESC>.
  -- It doesn't have ctrl-z so please always commit before using it.
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = {
      default = {
        find = {
          -- pick one of item in find_engine [ fd, rg ]
          cmd = "fd",
          options = {}
        },
        replace = {
          -- pick one of item in [ sed, oxi ]
          cmd = "sed"
        },
      },
      is_insert_mode = true,    -- start open panel on is_insert_mode
      is_block_ui_break = true, -- prevent the UI from breaking
      mapping = {
        ["toggle_line"] = {
          map = "d",
          cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
          desc = "toggle item.",
        },
        ["enter_file"] = {
          map = "<cr>",
          cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
          desc = "open file.",
        },
        ["send_to_qf"] = {
          map = "sqf",
          cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
          desc = "send all items to quickfix.",
        },
        ["replace_cmd"] = {
          map = "src",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "replace command.",
        },
        ["show_option_menu"] = {
          map = "so",
          cmd = "<cmd>lua require('spectre').show_options()<CR>",
          desc = "show options.",
        },
        ["run_current_replace"] = {
          map = "c",
          cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
          desc = "confirm item.",
        },
        ["run_replace"] = {
          map = "R",
          cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
          desc = "replace all.",
        },
        ["change_view_mode"] = {
          map = "sv",
          cmd = "<cmd>lua require('spectre').change_view()<CR>",
          desc = "results view mode.",
        },
        ["change_replace_sed"] = {
          map = "srs",
          cmd = "<cmd>lua require('spectre').change_engine_replace('sed')<CR>",
          desc = "use sed to replace.",
        },
        ["change_replace_oxi"] = {
          map = "sro",
          cmd = "<cmd>lua require('spectre').change_engine_replace('oxi')<CR>",
          desc = "use oxi to replace.",
        },
        ["toggle_live_update"] = {
          map = "sar",
          cmd = "<cmd>lua require('spectre').toggle_live_update()<CR>",
          desc = "auto refresh changes when nvim writes a file.",
        },
        ["resume_last_search"] = {
          map = "sl",
          cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
          desc = "repeat last search.",
        },
        ["insert_qwerty"] = {
          map = "i",
          cmd = "<cmd>startinsert<CR>",
          desc = "insert (qwerty).",
        },
        ["insert_colemak"] = {
          map = "o",
          cmd = "<cmd>startinsert<CR>",
          desc = "insert (colemak).",
        },
        ["quit"] = {
          map = "q",
          cmd = "<cmd>lua require('spectre').close()<CR>",
          desc = "quit.",
        },
      },
    },
  },

  -- [neotree]
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    cmd = "Neotree",
    opts = function()
      vim.g.neo_tree_remove_legacy_commands = true
      local utils = require("base.utils")
      local get_icon = utils.get_icon
      return {
        auto_clean_after_session_restore = true,
        close_if_last_window = true,
        buffers = {
          show_unloaded = true
        },
        sources = { "filesystem", "buffers", "git_status" },
        source_selector = {
          winbar = true,
          content_layout = "center",
          sources = {
            {
              source = "buffers",
              display_name = get_icon("DefaultFile", true) .. " Bufs",
            },
            {
              source = "filesystem",
              display_name = get_icon("FolderClosed", true) .. " File",
            },
            {
              source = "git_status",
              display_name = get_icon("Git", true) .. " Git",
            },
            {
              source = "diagnostics",
              display_name = get_icon("Diagnostic", true) .. " Diagnostic",
            },
          },
        },
        default_component_configs = {
          indent = { padding = 0 },
          icon = {
            folder_closed = get_icon("FolderClosed"),
            folder_open = get_icon("FolderOpen"),
            folder_empty = get_icon("FolderEmpty"),
            folder_empty_open = get_icon("FolderEmpty"),
            default = get_icon("DefaultFile"),
          },
          modified = { symbol = get_icon("FileModified") },
          git_status = {
            symbols = {
              added = get_icon("GitAdd"),
              deleted = get_icon("GitDelete"),
              modified = get_icon("GitChange"),
              renamed = get_icon("GitRenamed"),
              untracked = get_icon("GitUntracked"),
              ignored = get_icon("GitIgnored"),
              unstaged = get_icon("GitUnstaged"),
              staged = get_icon("GitStaged"),
              conflict = get_icon("GitConflict"),
            },
          },
        },
        -- A command is a function that we can assign to a mapping (below)
        commands = {
          system_open = function(state)
            require("base.utils").open_with_program(state.tree:get_node():get_id())
          end,
          parent_or_close = function(state)
            local node = state.tree:get_node()
            if
                (node.type == "directory" or node:has_children())
                and node:is_expanded()
            then
              state.commands.toggle_node(state)
            else
              require("neo-tree.ui.renderer").focus_node(
                state,
                node:get_parent_id()
              )
            end
          end,
          child_or_open = function(state)
            local node = state.tree:get_node()
            if node.type == "directory" or node:has_children() then
              if not node:is_expanded() then -- if unexpanded, expand
                state.commands.toggle_node(state)
              else                           -- if expanded and has children, seleect the next child
                require("neo-tree.ui.renderer").focus_node(
                  state,
                  node:get_child_ids()[1]
                )
              end
            else -- if not a directory just open it
              state.commands.open(state)
            end
          end,
          copy_selector = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify

            local results = {
              e = { val = modify(filename, ":e"), msg = "Extension only" },
              f = { val = filename, msg = "Filename" },
              F = {
                val = modify(filename, ":r"),
                msg = "Filename w/o extension",
              },
              h = {
                val = modify(filepath, ":~"),
                msg = "Path relative to Home",
              },
              p = {
                val = modify(filepath, ":."),
                msg = "Path relative to CWD",
              },
              P = { val = filepath, msg = "Absolute path" },
            }

            local messages = {
              { "\nChoose to copy to clipboard:\n", "Normal" },
            }
            for i, result in pairs(results) do
              if result.val and result.val ~= "" then
                vim.list_extend(messages, {
                  { ("%s."):format(i),           "Identifier" },
                  { (" %s: "):format(result.msg) },
                  { result.val,                  "String" },
                  { "\n" },
                })
              end
            end
            vim.api.nvim_echo(messages, false, {})
            local result = results[vim.fn.getcharstr()]
            if result and result.val and result.val ~= "" then
              vim.notify("Copied: " .. result.val)
              vim.fn.setreg("+", result.val)
            end
          end,
          find_in_dir = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            require("telescope.builtin").find_files {
              cwd = node.type == "directory" and path
                  or vim.fn.fnamemodify(path, ":h"),
            }
          end,
        },
        window = {
          width = 30,
          mappings = {
            ["<space>"] = false,
            ["<S-CR>"] = "system_open",
            ["[b"] = "prev_source",
            ["]b"] = "next_source",
            F = utils.is_available("telescope.nvim") and "find_in_dir" or nil,
            O = "system_open",
            Y = "copy_selector",
            h = "parent_or_close",
            l = "child_or_open",
          },
        },
        filesystem = {
          follow_current_file = {
            enabled = true,
          },
          hijack_netrw_behavior = "open_current",
          use_libuv_file_watcher = true,
        },
        event_handlers = {
          {
            event = "neo_tree_buffer_enter",
            handler = function(_) vim.opt_local.signcolumn = "auto" end,
          },
        },
      }
    end,
  },

  --  code [folding mod] + [promise-asyn] dependency
  --  https://github.com/kevinhwang91/nvim-ufo
  --  https://github.com/kevinhwang91/promise-async
  {
    "kevinhwang91/nvim-ufo",
    event = { "User BaseFile" },
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      preview = {
        mappings = {
          scrollB = "<C-b>",
          scrollF = "<C-f>",
          scrollU = "<C-u>",
          scrollD = "<C-d>",
        },
      },
      provider_selector = function(_, filetype, buftype)
        local function handleFallbackException(bufnr, err, providerName)
          if type(err) == "string" and err:match "UfoFallbackException" then
            return require("ufo").getFolds(bufnr, providerName)
          else
            return require("promise").reject(err)
          end
        end

        -- only use indent until a file is opened
        return (filetype == "" or buftype == "nofile") and "indent"
            or function(bufnr)
              return require("ufo")
                  .getFolds(bufnr, "lsp")
                  :catch(
                    function(err)
                      return handleFallbackException(bufnr, err, "treesitter")
                    end
                  )
                  :catch(
                    function(err)
                      return handleFallbackException(bufnr, err, "indent")
                    end
                  )
            end
      end,
    },
  },

  --  nvim-neoclip [nvim clipboard]
  --  https://github.com/AckslD/nvim-neoclip.lua
  --  Read their docs to enable cross-session history.
  {
    "AckslD/nvim-neoclip.lua",
    requires = 'nvim-telescope/telescope.nvim',
    event = "User BaseFile",
    opts = {}
  },

  --  zen-mode.nvim [distraction free mode]
  --  https://github.com/folke/zen-mode.nvim
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        width = .5
      }
    }
  },

  --  suda.nvim [write as sudo]
  --  https://github.com/lambdalisue/suda.vim
  {
    "lambdalisue/vim-suda",
    cmd = { "SudaRead", "SudaWrite" },
  },

  --  vim-matchup [improved % motion]
  --  https://github.com/andymass/vim-matchup
  {
    "andymass/vim-matchup",
    event = "User BaseDefered",
    config = function()
      vim.g.matchup_matchparen_deferred = 1   -- work async
      vim.g.matchup_matchparen_offscreen = {} -- disable status bar icon
    end,
  },

  --  hop.nvim [go to word visually]
  --  https://github.com/smoka7/hop.nvim
  {
    "smoka7/hop.nvim",
    cmd = { "HopWord" },
    opts = { keys = "etovxqpdygfblzhckisuran" }
  },

  --  nvim-autopairs [auto close brackets]
  --  https://github.com/windwp/nvim-autopairs
  --  It's disabled by default, you can enable it with <space>ua
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = "windwp/nvim-ts-autotag",
    opts = {
      check_ts = true,
      ts_config = { java = false },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)
      if not vim.g.autopairs_enabled then npairs.disable() end

      local is_cmp_loaded, cmp = pcall(require, "cmp")
      if is_cmp_loaded then
        cmp.event:on(
          "confirm_done",
          require("nvim-autopairs.completion.cmp").on_confirm_done {
            tex = false }
        )
      end
    end
  },

  -- nvim-ts-autotag [auto close html tags]
  -- https://github.com/windwp/nvim-ts-autotag
  -- Adds support for HTML tags to the plugin nvim-autopairs.
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "windwp/nvim-autopairs"
    },
    opts = {}
  },

  -- lsp_signature.nvim [auto params help]
  -- https://github.com/ray-x/lsp_signature.nvim
  {
    "ray-x/lsp_signature.nvim",
    event = "User BaseFile",
    opts = function()
      -- Apply globals from 1-options.lua
      local is_enabled = vim.g.lsp_signature_enabled
      local round_borders = {}
      if vim.g.lsp_round_borders_enabled then
        round_borders = { border = 'rounded' }
      end
      return {
        -- Window mode
        floating_window = is_enabled, -- Display it as floating window.
        hi_parameter = "IncSearch",   -- Color to highlight floating window.
        handler_opts = round_borders, -- Window style

        -- Hint mode
        hint_enable = false, -- Display it as hint.
        hint_prefix = "👈 ",

        -- Additionally, you can use <space>uH to toggle inlay hints.
        toggle_key_flip_floatwin_setting = is_enabled
      }
    end,
    config = function(_, opts) require('lsp_signature').setup(opts) end
  },

  -- nvim-lightbulb [lightbulb for code actions]
  -- https://github.com/kosayoda/nvim-lightbulb
  -- Show a lightbulb where a code action is available
  {
    'kosayoda/nvim-lightbulb',
    enabled = vim.g.codeactions_enabled,
    event = "User BaseFile",
    opts = {
      action_kinds = { -- show only for relevant code actions.
        "quickfix",
      },
      ignore = {
        ft = { "lua", "markdown" }, -- ignore filetypes with bad code actions.
      },
      autocmd = {
        enabled = true,
        updatetime = 100,
      },
      sign = { enabled = false },
      virtual_text = {
        enabled = true,
        text = require("base.utils").get_icon("Lightbulb")
      }
    },
    config = function(_, opts) require("nvim-lightbulb").setup(opts) end
  },

  -- distroupdate.nvim [distro update]
  -- https://github.com/zeioth/distroupdate.nvim
  {
    "zeioth/hot-reload.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "User BaseFile",
    opts = function()
      local utils = require("base.utils")
      local config_dir = utils.os_path(vim.fn.stdpath "config" .. "/lua/base/")
      return {
        notify = true,
        reload_files = {
          config_dir .. "1-options.lua",
          config_dir .. "4-mappings.lua"
        },
        reload_callback = function()
          vim.cmd(":silent! colorscheme " .. vim.g.default_colorscheme) -- nvim     colorscheme reload command
          vim.cmd(":silent! doautocmd ColorScheme")                     -- heirline colorscheme reload event
        end
      }
    end
  },

  -- distroupdate.nvim [distro update]
  -- https://github.com/zeioth/distroupdate.nvim
  {
    "zeioth/distroupdate.nvim",
    event = "User BaseFile",
    cmd = {
      "DistroFreezePluginVersions",
      "DistroReadChangelog",
      "DistroReadVersion",
      "DistroUpdate",
      "DistroUpdateRevert"
    },
    opts = {
        channel = "stable" -- stable/nightly
    }
  },

} -- end of return
