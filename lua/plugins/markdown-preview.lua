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
    -- Gitiles-like layout in the colorscheme's colours, see
    -- user.markdown-preview-css.
    vim.g.mkdp_markdown_css = require("user.markdown-preview-css").path
    -- The plugin's defaults, except that [TOC] starts at h2 so the document
    -- title is left out, as Gitiles does. A user-set dict replaces the
    -- defaults wholesale, hence the full list.
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      uml = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = { level = 2 },
    }
  end,
  config = function()
    local css = require("user.markdown-preview-css")
    css.write()
    -- The colorscheme is applied a second time once the terminal background
    -- is detected, which can land after this plugin loads when nvim starts on
    -- a Markdown file. Rewriting on every load keeps the final palette, and
    -- an open preview takes any later change on reload.
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("user_markdown_preview_css", { clear = true }),
      callback = css.write,
      desc = "Regenerate the Markdown preview stylesheet",
    })
  end,
}
