local palette = {
  foreground = "#d8dadf",
  cursor = "#cccccc",
  color0 = "#282c34",
  color1 = "#e06c75",
  color2 = "#98c379",
  color3 = "#e5c07b",
  color4 = "#61afef",
  color5 = "#be5046",
  color6 = "#56b6c2",
  color7 = "#979eab",
  color8 = "#393e48",
  color9 = "#d19a66",
  color10 = "#56b6c2",
  color11 = "#e5c07b",
  color12 = "#61afef",
  color13 = "#be5046",
  color14 = "#56b6c2",
  color15 = "#abb2bf",
  color16 = "#3d424c",
  selection_foreground = "#282c34",
  selection_background = "#979eab",
}

local groups = {
  border = palette.color16,
  error = palette.color1,
  hint = palette.color4,
  info = palette.color2,
  ok = palette.color2,
  panel = palette.color8,
  success = palette.color2,
  warning = palette.color3,

  git_change = palette.color3,
  git_add = palette.color2,
  git_delete = palette.color1,
}

local function dim(hex, percentage)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  local blendFactor = percentage / 100
  r = math.floor(r + (255 - r) * blendFactor)
  g = math.floor(g + (255 - g) * blendFactor)
  b = math.floor(b + (255 - b) * blendFactor)

  return string.format("#%02X%02X%02X", r, g, b)
end

vim.g.terminal_color_0 = palette.color0   -- black
vim.g.terminal_color_1 = palette.color1   -- red
vim.g.terminal_color_2 = palette.color2   -- green
vim.g.terminal_color_3 = palette.color3   -- yellow
vim.g.terminal_color_4 = palette.color4   -- blue
vim.g.terminal_color_5 = palette.color5   -- magenta
vim.g.terminal_color_6 = palette.color6   -- cyan
vim.g.terminal_color_7 = palette.color7   -- white
vim.g.terminal_color_8 = palette.color8   -- bright black
vim.g.terminal_color_9 = palette.color9   -- bright red
vim.g.terminal_color_10 = palette.color10 -- bright green
vim.g.terminal_color_11 = palette.color11 -- bright yellow
vim.g.terminal_color_12 = palette.color12 -- bright blue
vim.g.terminal_color_13 = palette.color13 -- bright magenta
vim.g.terminal_color_14 = palette.color14 -- bright cyan
vim.g.terminal_color_15 = palette.color15 -- bright white

local highlights = {
  ColorColumn = { bg = dim(palette.color0, 3) },
  Conceal = { bg = "NONE" },
  CurSearch = { fg = palette.color0, bg = palette.color3, bold = true },
  Cursor = { fg = palette.cursor, bg = palette.highlight_high },
  CursorColumn = { bg = palette.color0 },
  CursorLine = { bg = dim(palette.color0, 3) },
  CursorLineNr = { fg = palette.foreground, bg = palette.color8, bold = true },
  DiffAdd = { fg = groups.git_add },
  DiffChange = { fg = groups.git_change },
  DiffDelete = { fg = groups.git_delete },
  DiffText = { fg = palette.foreground },
  diffAdded = { link = "DiffAdd" },
  diffChanged = { link = "DiffChange" },
  diffRemoved = { link = "DiffDelete" },
  Directory = { fg = palette.color10, bold = true },
  ErrorMsg = { fg = palette.color1, bold = true },
  FoldColumn = { fg = palette.color7 },
  Folded = { fg = palette.foreground, bg = groups.panel },
  IncSearch = { link = "CurSearch" },
  LineNr = { fg = dim(palette.color8, 25) },
  MatchParen = { bg = palette.color16, bold = true },
  ModeMsg = { fg = palette.color15 },
  MoreMsg = { fg = palette.color14 },
  NonText = { fg = palette.color7 },
  Normal = { fg = palette.foreground, bg = palette.color0 },
  NormalNC = { link = "Normal" },
  NvimInternalError = { link = "ErrorMsg" },
  Pmenu = { fg = palette.color15, bg = groups.panel },
  PmenuExtra = { fg = palette.color7, bg = groups.panel },
  PmenuExtraSel = { fg = palette.color15, bg = palette.color0 },
  PmenuKind = { fg = palette.color10, bg = groups.panel },
  PmenuKindSel = { fg = palette.color15, bg = palette.color0 },
  PmenuSbar = { bg = groups.panel },
  PmenuSel = { fg = palette.color4, bg = palette.color16 },
  PmenuThumb = { bg = palette.color7 },
  Question = { fg = palette.color3 },
  RedrawDebugClear = { fg = palette.color0, bg = palette.color3 },
  RedrawDebugComposed = { fg = palette.color0, bg = palette.color4 },
  RedrawDebugRecompose = { fg = palette.color0, bg = palette.love },
  Search = { bg = palette.color13 },
  SpecialKey = { fg = palette.color10 },
  SpellBad = { sp = palette.color15, undercurl = true },
  SpellCap = { sp = palette.color15, undercurl = true },
  SpellLocal = { sp = palette.color15, undercurl = true },
  SpellRare = { sp = palette.color15, undercurl = true },
  StatusLine = { fg = palette.color15, bg = groups.panel },
  StatusLineNC = { fg = palette.color7, bg = groups.panel },
  StatusLineTerm = { fg = palette.color0, bg = palette.color4 },
  StatusLineTermNC = { fg = palette.color0, bg = palette.color4 },
  Substitute = { link = "IncSearch" },
  TabLine = { fg = palette.color15, bg = groups.panel },
  TabLineFill = { bg = groups.panel },
  TabLineSel = { fg = palette.foreground, bg = palette.color0, bold = true },
  Title = { fg = palette.color10, bold = true },
  VertSplit = { fg = groups.border },
  Visual = { bg = palette.color8 },
  WarningMsg = { fg = groups.warning, bold = true },
  WildMenu = { link = "IncSearch" },
  WinBar = { fg = palette.color15, bg = groups.panel },
  WinBarNC = { fg = palette.color7, bg = groups.panel },
  WinSeparator = { fg = groups.border },

  DiagnosticError = { fg = groups.error },
  DiagnosticHint = { fg = groups.hint },
  DiagnosticInfo = { fg = groups.info },
  DiagnosticOk = { fg = groups.ok },
  DiagnosticWarn = { fg = groups.warning },
  DiagnosticDefaultError = { link = "DiagnosticError" },
  DiagnosticDefaultHint = { link = "DiagnosticHint" },
  DiagnosticDefaultInfo = { link = "DiagnosticInfo" },
  DiagnosticDefaultOk = { link = "DiagnosticOk" },
  DiagnosticDefaultWarn = { link = "DiagnosticWarn" },
  DiagnosticFloatingError = { link = "DiagnosticError" },
  DiagnosticFloatingHint = { link = "DiagnosticHint" },
  DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
  DiagnosticFloatingOk = { link = "DiagnosticOk" },
  DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
  DiagnosticSignError = { link = "DiagnosticError" },
  DiagnosticSignHint = { link = "DiagnosticHint" },
  DiagnosticSignInfo = { link = "DiagnosticInfo" },
  DiagnosticSignOk = { link = "DiagnosticOk" },
  DiagnosticSignWarn = { link = "DiagnosticWarn" },
  DiagnosticUnderlineError = { sp = groups.error, undercurl = true },
  DiagnosticUnderlineHint = { sp = groups.hint, undercurl = true },
  DiagnosticUnderlineInfo = { sp = groups.info, undercurl = true },
  DiagnosticUnderlineOk = { sp = groups.ok, undercurl = true },
  DiagnosticUnderlineWarn = { sp = groups.warning, undercurl = true },
  DiagnosticVirtualTextError = { fg = groups.error },
  DiagnosticVirtualTextHint = { fg = groups.hint },
  DiagnosticVirtualTextInfo = { fg = groups.info },
  DiagnosticVirtualTextOk = { fg = groups.ok },
  DiagnosticVirtualTextWarn = { fg = groups.warning },

  Boolean = { fg = palette.color4 },
  Character = { fg = palette.color3 },
  Comment = { fg = palette.color9, italic = true },
  Conditional = { fg = palette.color4 },
  Constant = { fg = palette.color3 },
  Debug = { fg = palette.color4 },
  Define = { fg = palette.color14 },
  Delimiter = { fg = palette.color15 },
  Error = { fg = palette.love },
  Exception = { fg = palette.color4 },
  Float = { fg = palette.color3 },
  Function = { fg = palette.color1 },
  Identifier = { fg = palette.foreground },
  Include = { fg = palette.color4 },
  Keyword = { fg = palette.color4 },
  Label = { fg = palette.color10 },
  LspCodeLens = { fg = palette.color15 },
  LspCodeLensSeparator = { fg = palette.color7 },
  LspInlayHint = { fg = dim(palette.color16, 20) },
  LspReferenceRead = { bg = palette.color16 },
  LspReferenceText = {},
  LspReferenceWrite = {},
  Macro = { fg = palette.color14 },
  Number = { fg = palette.color3 },
  Operator = { fg = palette.color15 },
  PreCondit = { fg = palette.color14 },
  PreProc = { link = "PreCondit" },
  Repeat = { fg = palette.color4 },
  Special = { fg = palette.color10 },
  SpecialChar = { link = "Special" },
  SpecialComment = { fg = palette.color9, italic = true },
  Statement = { fg = palette.color4, bold = true },
  StorageClass = { fg = palette.color10 },
  String = { fg = palette.color2 },
  Structure = { fg = palette.color10 },
  Tag = { fg = palette.color10 },
  Todo = { fg = palette.color2, bg = palette.color1 },
  Type = { fg = palette.color10 },
  Whitespace = { fg = dim(palette.color8, 10) },
  TypeDef = { link = "Type" },
  Underlined = { fg = palette.color14, underline = true },

  healthError = { fg = groups.error },
  healthSuccess = { fg = groups.success },
  healthWarning = { fg = groups.warning },

  SnacksPickerCol = { fg = palette.foreground, bg = palette.color8, bold = true },
  SnacksPickerTitle = { fg = palette.foreground, bg = palette.color8, bold = true },
  SnacksPickerListCursorLine = { bg = dim(palette.color0, 3) },
  SnacksPickerMatch = { bg = palette.color13, fg = palette.foreground },
  SnacksPickerBorder = { fg = palette.color8, bg = palette.color8 },

  SnacksPicker = { link = "NormalFloat" },
  SnacksPickerPreview = { bg = dim(palette.color0, 3) },
  SnacksPickerFile = { fg = palette.foreground },
  SnacksPickerDir = { fg = palette.color7 },
  FloatBorder = { fg = groups.border, bg = "NONE" },
  FloatTitle = { fg = palette.color10, bg = "NONE", bold = true },
  NormalFloat = { bg = palette.color8, fg = palette.foreground },
  SignColumn = { fg = palette.foreground, bg = "NONE" },

  GitSignsAdd = { fg = groups.git_add, bg = "NONE" },
  GitSignsChange = { fg = groups.git_change, bg = "NONE" },
  GitSignsDelete = { fg = groups.git_delete, bg = "NONE" },
  SignAdd = { fg = groups.git_add, bg = "NONE" },
  SignChange = { fg = groups.git_change, bg = "NONE" },
  SignDelete = { fg = groups.git_delete, bg = "NONE" },

  FlashBackdrop = { bg = palette.color0, fg = palette.color7 },
  FlashMatch = { bg = palette.color0, fg = palette.color9 },
  FlashCurrent = { bg = palette.color0, fg = palette.color9, },
  FlashLabel = { bg = palette.color0, fg = palette.color2, bold = true },

  ["@field"] = { fg = palette.foreground },
  ["@function"] = { fg = palette.color4 },
  ["@method"] = { fg = palette.color4 },
  ["@parameter"] = { fg = palette.foreground, bold = true },
  ["@parameter.bash"] = { fg = palette.foreground },
  ["@string.escape"] = { fg = palette.color10 },
  ["@constructor"] = { fg = palette.color4 },
  ["@attribute"] = { fg = palette.foreground },
  ["@variable"] = { fg = palette.foreground },
  ["@variable.builtin"] = { fg = palette.foreground },
  ["@variable.member"] = { fg = palette.foreground },
  ["@variable.parameter"] = { fg = palette.foreground },
  ["@punctuation.special"] = { fg = palette.foreground },
  ["@property.yaml"] = { fg = palette.foreground },
}

for group, highlight in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, highlight)
end
