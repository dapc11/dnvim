local function dropdown(...)
  return vim.tbl_deep_extend("force", {
    fzf_opts = { ["--layout"] = "reverse" },
    winopts = {
      height = 0.90,
      width = 0.80,
      preview = { hidden = "nohidden", layout = "vertical" },
    },
  }, ...)
end

return {
  { "junegunn/fzf", build = "./install --bin" },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      "max-perf",
      fzf_opts = { ["--layout"] = "reverse" },
      winopts = { preview = { default = "builtin", layout = "vertical" } },
      keymap = {
        builtin = {
          ["<C-p>"] = "toggle-preview",
        },
      },
      oldfiles = dropdown({
        prompt = " History: ",
        cwd_only = true,
      }),
      files = dropdown({
        prompt = " Files: ",
      }),
      buffers = dropdown({
        prompt = "﬘ Buffers: ",
        winopts = {
          height = 0.60,
          width = 0.50,

          preview = { hidden = "hidden" },
        },
      }),
      keymaps = dropdown({
        prompt = " Keymaps: ",
        winopts = { width = 0.7 },
      }),
    },
  },
}
