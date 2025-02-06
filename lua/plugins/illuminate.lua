return {
  "RRethy/vim-illuminate",
  config = function()
    require("illuminate").configure({
      -- providers: provider used to get references in the buffer, ordered by priority
      providers = {
        "lsp",
      },
      large_file_cutoff = 1000,
      -- large_file_config: config to use for large files (based on large_file_cutoff).
      -- Supports the same keys passed to .configure
      -- If nil, vim-illuminate will be disabled for large files.
      large_file_overrides = nil,
      min_count_to_highlight = 2,
    })
  end,
}
