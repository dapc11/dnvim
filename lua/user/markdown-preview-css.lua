--- Stylesheet for markdown-preview.nvim in the palette of the current
--- colorscheme. assets/markdown-preview.css supplies the layout, typography
--- and fallback colours; this appends the base colours read from highlight
--- groups and writes the result to a cache file, which the plugin reads on
--- every page load. Only surfaces, text, borders and links follow the
--- colorscheme: the groups for Markdown source (red bold, a colour per heading
--- level) read as noise on a rendered page, where typography marks emphasis.
local M = {}

M.path = vim.fn.stdpath("cache") .. "/markdown-preview.css"
local TEMPLATE = vim.fn.stdpath("config") .. "/assets/markdown-preview.css"

--- Custom properties: { property, attribute, groups }. The first group with
--- the attribute set wins; a property that resolves nowhere keeps the
--- template's value.
local VARS = {
  { "md-text", "fg", { "Normal" } },
  { "md-bg", "bg", { "Normal" } },
  { "md-muted", "fg", { "Comment" } },
  { "md-border", "bg", { "Visual", "CursorLine" } },
  { "md-hr", "bg", { "Visual", "CursorLine" } },
  { "md-link", "fg", { "@markup.link.url", "Underlined", "Function" } },
  { "md-link-visited", "fg", { "@markup.link.url", "Underlined", "Function" } },
  { "md-table-border", "bg", { "Visual", "CursorLine" } },
  { "md-th-bg", "bg", { "CursorLine", "ColorColumn" } },
  { "md-code-bg", "bg", { "CursorLine", "ColorColumn" } },
  { "md-pre-bg", "bg", { "NormalFloat", "Pmenu" } },
  { "md-pre-border", "bg", { "Visual", "CursorLine" } },
  { "md-quote-bg", "bg", { "CursorLine", "ColorColumn" } },
  { "md-quote-border", "fg", { "Comment" } },
  { "md-toc-bg", "bg", { "NormalFloat", "Pmenu" } },
  { "md-toc-border", "bg", { "Visual", "CursorLine" } },
  -- The plugin's page.css: the filename header and the area around the page.
  { "foreground-color", "fg", { "Normal" } },
  { "background-color", "bg", { "StatusLine", "NormalFloat" } },
  { "border-color", "bg", { "Visual", "CursorLine" } },
  { "secondary-background-color", "bg", { "NormalFloat", "Normal" } },
}

--- Value of `attr` in the first group among `groups` that sets it.
--- Treesitter captures fall back from @a.b.c to @a.b and @a when drawn, but
--- nvim_get_hl does not, so the parents are tried in between.
---@return integer|nil
local function find(groups, attr)
  for _, name in ipairs(groups) do
    local candidate = name
    while candidate do
      local value = vim.api.nvim_get_hl(0, { name = candidate, link = false })[attr]
      if value then
        return value
      end
      candidate = candidate:match("^(@.+)%.[^.]+$")
    end
  end
end

local function generate()
  -- [data-theme] as well as :root, as the plugin sets its theme variables there.
  local lines = {
    "/* Generated from the Neovim colorscheme by user.markdown-preview-css. */",
    ":root, [data-theme] {",
  }
  for _, var in ipairs(VARS) do
    local value = find(var[3], var[2])
    if value then
      table.insert(lines, string.format("  --%s: #%06x;", var[1], value))
    end
  end
  table.insert(lines, "}")
  return table.concat(lines, "\n") .. "\n"
end

--- Write the stylesheet for the colorscheme in effect now.
function M.write()
  local template = assert(io.open(TEMPLATE)):read("a")
  vim.fn.mkdir(vim.fs.dirname(M.path), "p")
  local file = assert(io.open(M.path, "w"))
  file:write(template, "\n", generate())
  file:close()
end

return M
