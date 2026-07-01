local storage = vim.fn.stdpath("data") .. "/recent_files.txt"

local function abbreviate_path(file)
  local home = vim.fn.expand("~")
  local path = file:gsub("^" .. home, "~", 1)

  local dir = vim.fn.fnamemodify(file, ":h")
  local git_root
  while dir ~= "/" and dir ~= "" do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      git_root = dir
      break
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end

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
  if not file or file == "" or file:match("^%w+://") then
    return
  end
  if vim.bo.buftype ~= "" or vim.tbl_contains({ "help", "qf", "fugitive" }, vim.bo.filetype) then
    return
  end

  file = vim.fn.resolve(vim.fn.fnamemodify(file, ":p"))
  local pos = vim.api.nvim_win_get_cursor(0)
  local entry = string.format("%s:%d:%d", file, pos[1], pos[2] + 1)

  local lines = {}
  if vim.fn.filereadable(storage) == 1 then
    for line in io.lines(storage) do
      local existing_file = line:match("^([^:]+)")
      if existing_file and existing_file ~= file then
        table.insert(lines, line)
      end
    end
  end

  table.insert(lines, 1, entry)
  if #lines > 200 then
    lines[201] = nil
  end

  local fh = io.open(storage, "w")
  if fh then
    for _, line in ipairs(lines) do
      fh:write(line .. "\n")
    end
    fh:close()
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufLeave", "VimLeavePre" }, {
  callback = function()
    track_file(vim.fn.expand("%:p"))
  end,
})

return function(opts)
  opts = require("fzf-lua.config").normalize_opts(opts, "oldfiles") or {}
  local filter_cwd = opts.cwd and vim.fn.fnamemodify(opts.cwd, ":p"):gsub("/$", "")
  local current_file = vim.fn.expand("%:p")

  local positions = {}
  local files = {}

  if vim.fn.filereadable(storage) == 1 then
    for line in io.lines(storage) do
      local file = line:match("^([^:]+)")
      if file and vim.fn.filereadable(file) == 1 and file ~= current_file then
        if not filter_cwd or vim.startswith(file, filter_cwd .. "/") then
          positions[file] = line
          table.insert(files, file)
        end
      end
    end
  end

  return require("fzf-lua.core").fzf_exec(
    function(cb)
      for _, file in ipairs(files) do
        cb(abbreviate_path(file))
      end
      cb(nil)
    end,
    vim.tbl_extend("force", opts, {
      actions = {
        ["default"] = function(selected)
          if #selected == 0 then
            return
          end
          for file, line in pairs(positions) do
            if abbreviate_path(file) == selected[1] then
              local _, _, line_num, col = line:find("^[^:]+:(%d+):(%d+)")
              vim.cmd("edit " .. file)
              vim.api.nvim_win_set_cursor(0, { tonumber(line_num) or 1, (tonumber(col) or 1) - 1 })
              return
            end
          end
        end,
      },
    })
  )
end
-- -lua] fn_selected threw an error: /home/daniel/.config/nvim/lua/user/fzf-recent-files.lua:111: Curs
-- or position outside buffer                                                                             
-- stack traceback:                                                                                       
--         [C]: in function 'nvim_win_set_cursor'                                                         
--         /home/daniel/.config/nvim/lua/user/fzf-recent-files.lua:111: in function 'action'              
--         ...l/.local/share/nvim/lazy/fzf-lua/lua/fzf-lua/actions.lua:133: in function 'fn_selected'     
--         ...niel/.local/share/nvim/lazy/fzf-lua/lua/fzf-lua/core.lua:288: in function <...niel/.local/sh
-- are/nvim/lazy/fzf-lua/lua/fzf-lua/core.lua:278>                                                        
--         [C]: in function 'xpcall'                                                                      
--         ...niel/.local/share/nvim/lazy/fzf-lua/lua/fzf-lua/core.lua:278: in function <...niel/.local/sh
-- are/nvim/lazy/fzf-lua/lua/fzf-lua/core.lua:273>  
