local function load_zsh_env()
  local handle = io.popen("zsh -c 'source ~/.zshrc && env'")
  if handle then
    for line in handle:lines() do
      local key, value = line:match("^([^=]+)=(.*)$")
      if key and value then
        vim.env[key] = value
      end
    end
    handle:close()
  end
end

load_zsh_env()

vim.api.nvim_create_user_command("ReloadEnv", function()
  load_zsh_env()
  print("Environment variables reloaded from zsh")
end, { desc = "Reload zsh environment variables" })

vim.keymap.set("n", "<leader>re", ":ReloadEnv<CR>", { desc = "Reload environment" })

vim.o.guifont = "Monospace:h8"
vim.g.neovide_font_hinting = "none"
vim.g.neovide_font_edging = "antialias"
vim.g.neovide_scale_factor = 1
vim.g.neovide_confirm_quit = true
vim.g.neovide_cursor_trail_size = 0
vim.g.neovide_cursor_animation_length = 0.0
vim.g.neovide_scroll_animation_length = 0.0

vim.keymap.set("n", "<C-+>", function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1 end)
vim.keymap.set("n", "<C-->", function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1 end)
vim.keymap.set("n", "<C-0>", function() vim.g.neovide_scale_factor = 1 end)

vim.keymap.set("n", "<SC-s>", ":w<CR>")
vim.keymap.set("v", "<SC-c>", '"+y')
vim.keymap.set("n", "<SC-v>", "+p<CR>", { noremap = true, silent = true })
vim.keymap.set("!", "<SC-v>", "<C-R>+", { noremap = true, silent = true })
vim.keymap.set("t", "<SC-v>", "<C-R>+", { noremap = true, silent = true })
vim.keymap.set("v", "<SC-v>", "<C-R>+", { noremap = true, silent = true })
