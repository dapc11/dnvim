local should_profile = os.getenv("NVIM_PROFILE")
local prof = require("profile")
if should_profile then
  prof.instrument_autocmds()
  if should_profile:lower():match("^start") then
    prof.start("*")
  else
    prof.instrument("*")
  end
end

local function toggle_profile()
  if prof.is_recording() then
    prof.stop()
    vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "/tmp/profile.json" }, function(filename)
      if filename then
        prof.export(filename)
        vim.notify(string.format("Wrote %s", filename))
      end
    end)
  else
    prof.start("*")
  end
end
vim.keymap.set("n", "<leader>lp", toggle_profile, { desc = "Toggle Profile" })
