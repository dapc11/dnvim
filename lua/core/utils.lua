local M = {}

local g = vim.g

function M.bootstrap()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system({
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    print("Cloning packer...\nSetup DapcVim")
    vim.cmd([[packadd packer.nvim]])
  end
end

function M.disabled_builtins()
  g.loaded_gzip = true
  g.loaded_netrwPlugin = false
  g.loaded_netrwSettngs = false
  g.loaded_netrwFileHandlers = false
  g.loaded_tar = true
  g.loaded_tarPlugin = true
  g.zipPlugin = true
  g.loaded_zipPlugin = true
  g.loaded_2html_plugin = false
  g.loaded_remote_plugins = false
  g.loaded_matchit = false
end

function M.impatient()
  local impatient_ok, _ = pcall(require, "impatient")
  if impatient_ok then
    require("impatient").enable_profile()
  end
end

function M.compiled()
  local compiled_ok, _ = pcall(require, "packer_compiled")
  if compiled_ok then
    require("packer_compiled")
  end
end

function M.update()
  local Job = require("plenary.job")
  local errors = {}

  Job
    :new({
      command = "git",
      args = { "pull", "--ff-only" },
      cwd = vim.fn.stdpath("config"),
      on_start = function()
        print("Updating...")
      end,
      on_exit = function()
        if vim.tbl_isempty(errors) then
          print("Updated!")
        else
          table.insert(errors, 1, "Something went wrong! Please pull changes manually.")
          table.insert(errors, 2, "")
          print("Update failed!", {
            timeout = 30000,
          })
        end
      end,
      on_stderr = function(_, err)
        table.insert(errors, err)
      end,
    })
    :sync()
end
local api = vim.api
function M.blameVirtText()
  local ft = vim.fn.expand("%:h:t") -- get the current file extension
  if ft == "" then -- if we are in a scratch buffer or unknown filetype
    return
  end
  if ft == "bin" then -- if we are in nvim's terminal window
    return
  end
  api.nvim_buf_clear_namespace(0, 2, 0, -1) -- clear out virtual text from namespace 2 (the namespace we will set later)
  local text = ""
  local currFile = vim.fn.expand("%")
  local line = api.nvim_win_get_cursor(0)
  local blame = vim.fn.system(string.format("git blame -c -L %d,%d %s", line[1], line[1], currFile))
  local hash = vim.split(blame, "%s")[1]
  local cmd = string.format("git show %s ", hash) .. "--format='%an | %ar | %s'"
  if hash == "00000000" then
    text = "Not Committed Yet"
  else
    text = vim.fn.system(cmd)
    text = vim.split(text, "\n")[1]
    if text:find("fatal") then -- if the call to git show fails
      text = "Not Committed Yet"
    end
  end
  api.nvim_buf_set_virtual_text(0, 2, line[1] - 1, { { text, "GitLens" } }, {}) -- set virtual text for namespace 2 with the content from git and assign it to the higlight group 'GitLens'
end

function M.clearBlameVirtText() -- important for clearing out the text when our cursor moves
  api.nvim_buf_clear_namespace(0, 2, 0, -1)
end
return M
