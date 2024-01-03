_G.dd = function(...)
  require("util").dump(...)
end
_G.bt = function(...)
  require("util").bt(...)
end

vim.print = _G.dd
_G.lazyfile = { "BufReadPost", "BufNewFile", "BufWritePre" }

vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.cmd([[
  nmap > [
  nmap < ]
  omap > [
  omap < ]
  xmap > [
  xmap < ]
]])

require("config.lazy")()
require("config.options")
require("config.autocmds")
require("config.keymaps")

local should_profile = os.getenv("NVIM_PROFILE")
if should_profile then
  require("profile").instrument_autocmds()
  if should_profile:lower():match("^start") then
    require("profile").start("*")
  else
    require("profile").instrument("*")
  end
end

local function toggle_profile()
  local prof = require("profile")
  if prof.is_recording() then
    prof.stop()
    vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
      if filename then
        prof.export(filename)
        vim.notify(string.format("Wrote %s", filename))
      end
    end)
  else
    prof.start("*")
  end
end
vim.keymap.set("", "<leader>lp", toggle_profile, { desc = "Toggle Profile" })
