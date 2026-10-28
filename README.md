# DNvim

Neovim setup for Java, Kubernetes, Python and Golang development

## Markdown Preview

`:MarkdownPreview` renders the current buffer in a Chrome tab. The page updates live as the buffer
changes and scrolls along with the cursor, so nothing needs re-running after an edit.

- `:MarkdownPreview` — open the tab
- `:MarkdownPreviewStop` — close it
- `:MarkdownPreviewToggle` — either, bound to `<leader>cp` in markdown buffers

Requires `google-chrome` in `PATH`; pick another browser through `vim.g.mkdp_browser` in
`lua/plugins/markdown-preview.lua`.

The preview is served by a binary the `build` step downloads from the plugin's GitHub releases,
since this setup has node but no npm, npx or yarn. Run `:Lazy build markdown-preview.nvim` if the
preview ever fails to start.
