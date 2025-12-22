local function create_recent_files_picker()
  local core = require("fzf-lua.core")
  local config = require("fzf-lua.config")
  local utils = require("fzf-lua.utils")

  local storage_path = vim.fn.stdpath("data") .. "/recent_files.txt"
  local max_files = 200
  local home_path = vim.fn.expand("~")
  local git_root_cache = {}

  local function is_excluded_buffer(file)
    local buftype = vim.bo.buftype
    if buftype ~= "" then return true end

    local filetype = vim.bo.filetype
    if filetype == "help" or filetype == "qf" or filetype == "fugitive" then return true end

    return vim.fn.fnamemodify(file, ":t") == "COMMIT_EDITMSG"
  end

  local function write_file_list(files)
    local f = io.open(storage_path, "w")
    if not f then return end

    for i = 1, #files do
      f:write(files[i], "\n")
    end
    f:close()
  end

  local function find_git_root(file_path)
    local dir = vim.fn.fnamemodify(file_path, ":h")
    if git_root_cache[dir] then return git_root_cache[dir] end

    local original_dir = dir
    while dir ~= "/" and dir ~= "" do
      if vim.fn.isdirectory(dir .. "/.git") == 1 then
        git_root_cache[original_dir] = dir
        return dir
      end
      local parent = vim.fn.fnamemodify(dir, ":h")
      if parent == dir then break end
      dir = parent
    end

    git_root_cache[original_dir] = nil
  end

  local function abbreviate_path(abs_file)
    local path = abs_file:gsub("^" .. home_path, "~", 1)
    local git_root = find_git_root(abs_file)
    local segments = vim.split(path, "/")
    local repo_name = git_root and vim.fn.fnamemodify(git_root, ":t")

    for i = 1, #segments - 2 do
      if segments[i] ~= repo_name then
        segments[i] = segments[i]:sub(1, 1)
      end
    end

    return table.concat(segments, "/")
  end

  local function track_file(file)
    if not file or file == "" or file:match("^%w+://") or is_excluded_buffer(file) then
      return
    end

    file = vim.fn.resolve(vim.fn.fnamemodify(file, ":p"))
    local pos = vim.api.nvim_win_get_cursor(0)
    local entry = file .. ":" .. pos[1] .. ":" .. (pos[2] + 1)

    local files = {}
    local seen = {}
    local count = 0

    if vim.fn.filereadable(storage_path) == 1 then
      for line in io.lines(storage_path) do
        local existing_file = line:match("^([^:]+)")
        if existing_file and existing_file ~= file and not seen[existing_file] then
          count = count + 1
          files[count] = line
          seen[existing_file] = true
        end
      end
    end

    table.insert(files, 1, entry)
    if #files > max_files then
      for i = max_files + 1, #files do files[i] = nil end
    end

    write_file_list(files)
  end

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufLeave", "VimLeavePre" }, {
    callback = function() track_file(vim.fn.expand("%:p")) end,
  })

  local function load_files()
    local positions = {}
    local files = {}
    local seen = {}
    local current_file = vim.fn.expand("%:p")
    local count = 0

    if vim.fn.filereadable(storage_path) == 1 then
      for line in io.lines(storage_path) do
        if line ~= "" then
          local file = line:match("^([^:]+)")
          if file and vim.fn.filereadable(file) == 1 and not seen[file] and file ~= current_file then
            seen[file] = true
            positions[file] = line
            count = count + 1
            files[count] = file
          end
        end
      end
    end

    return positions, files
  end

  local function find_file_by_display_path(display_path, positions)
    for file in pairs(positions) do
      if abbreviate_path(vim.fn.fnamemodify(file, ":p")) == display_path then
        return file
      end
    end
  end

  local function parse_position(position_line)
    local _, _, line, col = position_line:find("^[^:]+:(%d+):(%d+)")
    return tonumber(line) or 1, tonumber(col) or 1
  end

  local function create_actions(positions)
    return {
      ["default"] = function(selected)
        if #selected == 0 then return end

        local file = find_file_by_display_path(selected[1], positions)
        if file then
          local line, col = parse_position(positions[file])
          vim.cmd("edit " .. file)
          vim.api.nvim_win_set_cursor(0, { line, col - 1 })
        end
      end,

      ["alt-q"] = function(selected)
        local qf_list = {}

        for i = 1, #selected do
          local file = find_file_by_display_path(selected[i], positions)
          if file then
            local line, col = parse_position(positions[file])
            qf_list[#qf_list + 1] = {
              filename = file,
              lnum = line,
              col = col,
              text = selected[i],
            }
          end
        end

        vim.fn.setqflist(qf_list)
        vim.cmd("copen")
      end,
    }
  end

  return function(opts)
    opts = config.normalize_opts(opts, "oldfiles")
    if not opts then return end

    local positions, files = load_files()

    opts.actions = create_actions(positions)
    opts.cwd = opts.cwd or utils.cwd()

    return core.fzf_exec(function(cb)
      for i = 1, #files do
        cb(abbreviate_path(vim.fn.fnamemodify(files[i], ":p")))
      end
      cb(nil)
    end, opts)
  end
end

return { {
  "otavioschwanck/fzf-lua-enchanted-files",
  dependencies = { "ibhagwan/fzf-lua" },
  config = function()
    vim.g.fzf_lua_enchanted_files = {
      max_history_per_cwd = 50,
    }
  end,
},
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons", "vijaymarupudi/nvim-fzf", "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function()
      local actions = require("fzf-lua.actions")
      local fzf = require("fzf-lua")
      fzf.setup({
        fzf_args = "--no-header",
        files = {
          git_icons = false,
          file_icons = false,
          fzf_opts = {
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
          },
          fd_opts = " --color=never --type f --hidden --follow --exclude .svn --exclude .git --exclude vendor",
        },
        grep = {
          fzf_opts = {
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-grep-history",
          },
          rg_glob = true,
          rg_glob_fn = function(query, _)
            query = query:gsub("[\r\n]+", ""):gsub("%s+$", "") -- remove carriage returns and trim
            local search_part, glob_part = query:match("^(.-)%s+%-%-(.*)$")
            if search_part then
              -- Return search terms as-is and glob flags separately
              glob_part = glob_part:gsub("^%s+", "") -- trim leading space
              local glob_flags = ""
              if glob_part ~= "" then
                -- Add **/ prefix if not already present
                if not glob_part:match("^%*%*/") and not glob_part:match("^/") then
                  glob_part = "**/" .. glob_part
                end
                glob_flags = "--iglob=" .. glob_part
              end
              return search_part, glob_flags
            else
              -- No -- found, return query as-is
              return query, ""
            end
          end,
          actions = {
            ["ctrl-h"] = { actions.toggle_ignore },
            ["ctrl-g"] = { actions.grep_lgrep },
          },
        },
        oldfiles = {
          git_icons = false,
          file_icons = false,
          fzf_opts = {
            ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
          },
          include_current_session = true,
        },
        previewers = {
          builtin = {
            -- fzf-lua is very fast, but it really struggled to preview a couple files
            -- in a repo. It turns out it was Treesitter having trouble parsing the files.
            -- With this change, the previewer will not add syntax highlighting to files larger than 100KB
            -- (Yes, I know you shouldn't have 100KB minified files in source control.)
            syntax_limit_b = 1024 * 100, -- 100KB
          },
        },
        git = {
          files = {
            fzf_opts = {
              ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-files-history",
            },
            cmd = "fd --color=never --type f --type l --exclude .git",
          },
        },
        fzf_colors = {
          ["bg"] = { "bg", "FzfLuaNormal" },
          ["bg+"] = { "bg", "CursorLine" },
          ["gutter"] = { "bg", "FzfLuaNormal" },
          ["hl+"] = { "fg", "Error" }, -- Current line match
          ["hl"] = { "fg", "Error" }, -- Other line matches
          ["separator"] = { "bg", "FzfLuaNormal" },
          ["scrollbar"] = { "fg", "CursorLine" },
          ["header"] = { "fg", "CursorLine" },
          ["spinner"] = { "fg", "CursorLine" },
          ["pointer"] = { "fg", "Normal" },
        },
        winopts = {
          preview = {
            hidden = "hidden",
          },
        },
        keymap = {
          builtin = {
            ["<C-?>"] = "toggle-help",
            ["<S-down>"] = "preview-page-down",
            ["<S-up>"] = "preview-page-up",
            ["<S-left>"] = "preview-page-reset",
          },
          fzf = {
            ["ctrl-z"] = "abort",
            ["ctrl-x"] = "unix-line-discard",
            ["ctrl-d"] = "half-page-down",
            ["ctrl-u"] = "half-page-up",
            ["ctrl-a"] = "beginning-of-line",
            ["ctrl-e"] = "end-of-line",
            ["alt-a"] = "toggle-all",
            ["shift-down"] = "preview-page-down",
            ["shift-up"] = "preview-page-up",
            ["ctrl-q"] = "select-all+accept",
            ["ctrl-n"] = "next-history",
            ["ctrl-p"] = "previous-history",
          },
        },
        actions = {
          files = {
            ["default"] = function(selected, opts)
              if #selected > 1 then
                local qf_list = {}
                for i = 1, #selected do
                  local file = fzf.path.entry_to_file(selected[i])
                  local text = selected[i]:match(":%d+:%d?%d?%d?%d?:?(.*)$")
                  table.insert(qf_list, {
                    filename = file.path,
                    lnum = file.line,
                    col = file.col,
                    text = text,
                  })
                end
                vim.fn.setqflist(qf_list)
                vim.cmd([[copen]])
              else
                actions.file_edit(selected, opts)
              end
            end,
            ["ctrl-x"] = actions.file_split,
            ["ctrl-v"] = actions.file_vsplit,
            ["ctrl-t"] = actions.file_tabedit,
            ["alt-q"] = actions.file_sel_to_qf,
            ["alt-l"] = actions.file_sel_to_ll,
          },
          buffers = {
            ["default"] = actions.buf_edit,
            ["ctrl-v"] = actions.buf_vsplit,
            ["ctrl-t"] = actions.buf_tabedit,
          },
        },
      })
    end,
    keys = function()
      local fzf = require("fzf-lua")
      local fzfe = require("fzf-lua-enchanted-files")
      local recent_files_picker = create_recent_files_picker()

      local list_files_from_branch_action = function(action, selected, o)
        local file = require("fzf-lua").path.entry_to_file(selected[1], o)
        local cmd = string.format("%s %s:%s", action, o.args, file.path)
        vim.cmd(cmd)
      end
      vim.api.nvim_create_user_command("ListFilesFromBranch", function(opts)
        require("fzf-lua").files {
          cmd = "git ls-tree -r --name-only " .. opts.args,
          prompt = opts.args .. "> ",
          actions = {
            ["default"] = function(selected, o)
              list_files_from_branch_action("Gedit", selected, o)
            end,
            ["ctrl-s"] = function(selected, o)
              list_files_from_branch_action("Gsplit", selected, o)
            end,
            ["ctrl-v"] = function(selected, o)
              list_files_from_branch_action("Gvsplit", selected, o)
            end,
          },
          previewer = false,
          preview = {
            type = "cmd",
            fn = function(items)
              local file = require("fzf-lua").path.entry_to_file(items[1])
              return string.format("git diff %s HEAD -- %s | delta", opts.args, file.path)
            end,
          },
        }
      end, {
        nargs = 1,
        force = true,
        complete = function()
          local branches = vim.fn.systemlist "git branch --all --sort=-committerdate"
          if vim.v.shell_error == 0 then
            return vim.tbl_map(function(x)
              return x:match("[^%s%*]+"):gsub("^remotes/", "")
            end, branches)
          end
        end,
      })
      return {
        { "<leader>r", recent_files_picker, desc = "Find Recent Files" },
        { "<leader>b", fzf.buffers, desc = "Find Open Buffers" },
        { "<leader>n", fzfe.files, desc = "Find Tracked Files" },
        { "<leader>N", fzf.git_status, desc = "Find Untracked Files" },
        { "<leader>fc", fzf.command_history, desc = "Find in Command History" },
        { "<M-x>", fzf.commands, desc = "Find Commands" },
        {
          "<leader>fä",
          function()
            fzfe.files({ cwd = "~/.config" })
          end,
          desc = "Find in Dotfiles",
        },
        {
          "<leader>fÄ",
          function()
            fzfe.files({ cwd = require("lazy.core.config").options.root })
          end,
          desc = "Find in Plugin Files",
        },
        {
          "<leader>fx",
          function()
            fzf.files({ cwd = "~/Downloads/" })
          end,
          desc = "Find in Downloads",
        },
        { "<leader>fh", fzf.helptags, desc = "Find Help" },
        { "<leader>fH", fzf.highlights, desc = "Find Highlights" },
        { "<leader><leader>", fzf.live_grep, desc = "Grep" },
        { "<leader>R", fzf.resume, desc = "Resume" },
        { "<leader><leader>", fzf.grep_visual, desc = "Live Grep Selection", mode = "v" },
        {
          "<leader><S-leader>",
          function()
            local cwd = vim.fn.expand("%:p:h:h")
            fzf.live_grep({ cwd = cwd })
          end,
          desc = "Live Grep in File Dir",
        },
        {
          "<leader><S-leader>",
          function()
            local cwd = vim.fn.expand("%:p:h:h")
            local selection = require("util.common").get_visual_selection()
            fzf.live_grep({ cwd = cwd, search = selection })
          end,
          desc = "Live Grep Selection in File Dir",
          mode = "v",
        },
        {
          "<leader><S-space>",
          function()
            local cwd = vim.fn.expand("%:p:h")
            local selection = require("util.common").get_visual_selection()
            fzf.live_grep({ cwd = cwd, search = selection })
          end,
          desc = "Live Grep in File Dir",
          mode = { "n", "v" },
        },
        { "<leader>zf", function() fzf.grep({ cwd = "~/notes/", path_shorten = true }) end, desc = "Search in Notes" },
        { "<leader>zb", function() fzf.files({ cwd = "~/notes/", path_shorten = true }) end, desc = "Browse Notes" },
        {
          "<C-f>",
          function()
            fzf.lgrep_curbuf({ search = require("util.common").get_visual_selection() })
          end,
          desc = "Live Grep Selection",
          mode = "v",
        },
        { "<C-f>", fzf.lgrep_curbuf, desc = "Find in Current Buffer" },
        {
          "<C-p>",
          function()
            require("util.common").fzf_projectionist()
          end,
          desc = "Find Project",
        },
      }
    end,
  } }
