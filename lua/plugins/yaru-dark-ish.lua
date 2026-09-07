-- Contrast fixes re-applied after each colorscheme load.
--
-- Comment was #5e5c64 on #262626 -- 2.3:1, under the 4.5:1 readability floor --
-- while the gitcommit `#` block around it spanned Comment, PreProc, Type and
-- Constant, so throwaway boilerplate shouted at up to 9:1. The completion label
-- used that same grey, and the selected row only raised the background: blink's
-- cursorline keeps `hl_params.bg` and drops fg (lib/window/cursor_line.lua), so
-- selecting a row took its label to 1.3:1 instead of lifting it, leaving just
-- the bold matched character visible. The label has to carry its own contrast.
local dim = "#918f9b" -- comments: 4.8:1, readable but still recessed
local dim2 = "#a5a3af" -- gitcommit file paths, one step up to stay scannable
local text = "#b0afac" -- palette subtext1; labels at 7.3:1, still 5.4:1 selected
local sel = "#383838" -- selected row: visible, yet keeps `text` above 5:1
local meta = "#82828c" -- source column, descriptions: 3.1:1 worst case
local match = "#87afff" -- palette blue, near-iso-luminant with `text`, so a
-- matched character reads as a hue shift rather than a brightness jump mid-word

local overrides = {
  Comment = { fg = dim, italic = true },

  -- One voice for the gitcommit block: structure from weight and a single
  -- luminance step, not four hues. The subject line stays the only warm thing.
  gitcommitHeader = { fg = dim, bold = true },
  gitcommitSelectedType = { fg = dim },
  gitcommitDiscardedType = { fg = dim },
  gitcommitUntracked = { fg = dim },
  gitcommitSelectedFile = { fg = dim2 },
  gitcommitDiscardedFile = { fg = dim2 },
  gitcommitUntrackedFile = { fg = dim2 },
  gitcommitBranch = { fg = dim2, bold = true },
  ["@comment.warning.gitcommit"] = { link = "Comment" },

  -- Completion menu. fg on the *Sel groups still serves the native popup;
  -- blink uses only their bg.
  Pmenu = { fg = text, bg = "#212121" },
  PmenuKind = { fg = text, bg = "#212121" },
  PmenuExtra = { fg = meta, bg = "#212121" },
  PmenuSel = { fg = text, bg = sel },
  PmenuKindSel = { fg = text, bg = sel },
  PmenuExtraSel = { fg = meta, bg = sel },
  PmenuMatch = { fg = match, bold = true },
  PmenuMatchSel = { fg = match, bg = sel, bold = true },
  PmenuThumb = { bg = "#565660" },
  BlinkCmpLabel = { link = "Pmenu" },
  BlinkCmpLabelDeprecated = { fg = meta, strikethrough = true },
  BlinkCmpMenuSelection = { bg = sel },
  BlinkCmpScrollBarThumb = { bg = "#565660" },
}

return {
  "dapc11/yaru-dark-ish.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    -- Registered before the first load so it also survives the second one.
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("ThemeTweaks", { clear = true }),
      pattern = "yaru-dark-ish",
      callback = function()
        for group, opts in pairs(overrides) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end,
    })

    vim.cmd.colorscheme("yaru-dark-ish")
    -- The terminal can only be asked for its background asynchronously, so the
    -- derived palette lands shortly after the first paint.
    require("user.terminal-bg").detect(function(palette)
      if not palette then
        return
      end
      vim.g.yaru_color_overrides = palette
      vim.cmd.colorscheme("yaru-dark-ish")
    end)
  end,
}
