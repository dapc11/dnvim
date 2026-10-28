--- :MarkdownPreview renders the current buffer in a Chrome tab. The page
--- updates live as the buffer changes, so there is nothing to re-run after an
--- edit, and it scrolls along with the cursor.
---
---   :MarkdownPreview        open the tab
---   :MarkdownPreviewStop    close it
---   :MarkdownPreviewToggle  either, bound to <leader>cp in ftplugin/markdown
---
--- The build step downloads a prebuilt server binary from the plugin's GitHub
--- releases into app/bin. The usual alternative, `yarn install` in app/, is not
--- an option here: node is installed but npm, npx and yarn are not.
return {
  "iamcco/markdown-preview.nvim",
  build = "cd app && ./install.sh",
  ft = "markdown",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_browser = "google-chrome"
    -- Leaving the buffer should not take the tab with it; :MarkdownPreviewStop
    -- closes it on request.
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_theme = "dark"
    -- Print the preview URL, so the tab can be reopened by hand after an
    -- accidental close.
    vim.g.mkdp_echo_preview_url = 1
  end,
}
