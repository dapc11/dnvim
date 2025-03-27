local p = {
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
  selection_background = "#979eab",
}

local groups = {
  border = p.color16,
  error = p.color1,
  hint = p.color4,
  info = p.color2,
  ok = p.color2,
  panel = p.color8,
  success = p.color2,
  warning = p.color3,

  git_change = p.color3,
  git_add = p.color2,
  git_delete = p.color1,
}

local function darken(hex, percentage)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  -- Convert percentage into a darkening factor
  local dimFactor = 1 - (percentage / 100)
  r = math.floor(r * dimFactor)
  g = math.floor(g * dimFactor)
  b = math.floor(b * dimFactor)

  return string.format("#%02X%02X%02X", r, g, b)
end

local function brighten(hex, percentage)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)

  local blendFactor = percentage / 100
  r = math.floor(r + (255 - r) * blendFactor)
  g = math.floor(g + (255 - g) * blendFactor)
  b = math.floor(b + (255 - b) * blendFactor)

  return string.format("#%02X%02X%02X", r, g, b)
end

vim.g.terminal_color_0 = p.color0 -- black
vim.g.terminal_color_1 = p.color1 -- red
vim.g.terminal_color_2 = p.color2 -- green
vim.g.terminal_color_3 = p.color3 -- yellow
vim.g.terminal_color_4 = p.color4 -- blue
vim.g.terminal_color_5 = p.color5 -- magenta
vim.g.terminal_color_6 = p.color6 -- cyan
vim.g.terminal_color_7 = p.color7 -- white
vim.g.terminal_color_8 = p.color8 -- bright black
vim.g.terminal_color_9 = p.color9 -- bright red
vim.g.terminal_color_10 = p.color10 -- bright green
vim.g.terminal_color_11 = p.color11 -- bright yellow
vim.g.terminal_color_12 = p.color12 -- bright blue
vim.g.terminal_color_13 = p.color13 -- bright magenta
vim.g.terminal_color_14 = p.color14 -- bright cyan
vim.g.terminal_color_15 = p.color15 -- bright white

local highlights = {
  ColorColumn = { bg = brighten(p.color0, 3) },
  Conceal = { bg = "NONE" },
  CurSearch = { fg = p.color0, bg = p.color3, bold = true },
  Cursor = { fg = p.cursor, bg = p.highlight_high },
  CursorColumn = { bg = p.color0 },
  CursorLine = { bg = brighten(p.color0, 3) },
  CursorLineNr = { bg = p.color8 },
  DiffAdd = { fg = groups.git_add },
  DiffChange = { fg = groups.git_change },
  DiffDelete = { fg = groups.git_delete },
  DiffText = { fg = p.foreground },
  diffAdded = { link = "DiffAdd" },
  diffChanged = { link = "DiffChange" },
  diffRemoved = { link = "DiffDelete" },
  Directory = { fg = p.color10, bold = true },
  ErrorMsg = { fg = p.color1, bold = true },
  FoldColumn = { fg = p.color7 },
  Folded = { fg = p.foreground, bg = groups.panel },
  IncSearch = { link = "CurSearch" },
  LineNr = { fg = brighten(p.color8, 25) },
  MatchParen = { bg = darken(p.color3, 10), fg = p.color8, bold = true },
  ModeMsg = { fg = p.color15 },
  MoreMsg = { fg = p.color14 },
  NonText = { fg = p.color7 },

  Normal = { fg = p.foreground, bg = p.color0 },
  NormalNC = { link = "Normal" },
  NvimInternalError = { link = "ErrorMsg" },
  Pmenu = { fg = p.color15, bg = groups.panel },
  PmenuExtra = { fg = p.color7, bg = groups.panel },
  PmenuExtraSel = { fg = p.color15, bg = p.color0 },
  PmenuKind = { fg = p.color10, bg = groups.panel },
  PmenuKindSel = { fg = p.color15, bg = p.color0 },
  PmenuSbar = { bg = groups.panel },
  PmenuSel = { fg = p.color4, bg = p.color16 },
  PmenuThumb = { bg = p.color7 },
  Question = { fg = p.color3 },
  RedrawDebugClear = { fg = p.color0, bg = p.color3 },
  RedrawDebugComposed = { fg = p.color0, bg = p.color4 },
  RedrawDebugRecompose = { fg = p.color0, bg = p.love },
  Search = { bg = brighten(p.color3, 40), fg = p.color0 },
  SpecialKey = { fg = p.color10 },
  SpellBad = { sp = p.color15, undercurl = true },
  SpellCap = { sp = p.color15, undercurl = true },
  SpellLocal = { sp = p.color15, undercurl = true },
  SpellRare = { sp = p.color15, undercurl = true },
  StatusLine = { fg = p.color15, bg = groups.panel },
  StatusLineNC = { fg = p.color7, bg = groups.panel },
  StatusLineTerm = { fg = p.color0, bg = p.color4 },
  StatusLineTermNC = { fg = p.color0, bg = p.color4 },
  Substitute = { link = "IncSearch" },
  TabLine = { fg = p.color15, bg = groups.panel },
  TabLineFill = { bg = groups.panel },
  TabLineSel = { fg = p.foreground, bg = p.color0, bold = true },
  Title = { fg = p.color10, bold = true },
  VertSplit = { fg = groups.border },
  Visual = { bg = p.color8 },
  WarningMsg = { fg = groups.warning, bold = true },
  WildMenu = { link = "IncSearch" },
  WinBar = { fg = p.color15, bg = groups.panel },
  WinBarNC = { fg = p.color7, bg = groups.panel },
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

  Boolean = { fg = p.color4 },
  Character = { fg = p.color3 },
  Comment = { fg = p.color9, italic = true },
  Conditional = { fg = p.color4 },
  Constant = { fg = p.color3 },
  Debug = { fg = p.color4 },
  Define = { fg = p.color14 },
  Delimiter = { fg = p.color15 },
  Error = { fg = p.love },
  Exception = { fg = p.color4 },
  Float = { fg = p.color3 },
  Function = { fg = p.color1, bold = true },
  Identifier = { fg = p.foreground },
  Include = { fg = p.color4 },
  Keyword = { fg = p.color4 },
  Label = { fg = p.color10 },
  LspCodeLens = { fg = p.color15 },
  LspCodeLensSeparator = { fg = p.color7 },
  LspInlayHint = { fg = brighten(p.color16, 20) },
  LspReferenceRead = { bg = p.color16, bold = true },
  LspReferenceText = {},
  LspReferenceWrite = {},
  Macro = { fg = p.color14 },
  Number = { fg = p.color3 },
  Operator = { fg = p.color15 },
  PreCondit = { fg = p.color14 },
  PreProc = { link = "PreCondit" },
  Repeat = { fg = p.color4 },
  Special = { fg = p.color10 },
  SpecialChar = { link = "Special" },
  SpecialComment = { fg = p.color9, italic = true },
  Statement = { fg = p.color4, bold = true },
  StorageClass = { fg = p.color10 },
  String = { fg = p.color2 },
  Structure = { fg = p.color10 },
  Tag = { fg = p.color10 },
  Todo = { fg = p.color2, bg = p.color1 },
  Type = { fg = p.color10 },
  Whitespace = { fg = brighten(p.color8, 10) },
  TypeDef = { link = "Type" },
  Underlined = { fg = p.color14, underline = true },

  healthError = { fg = groups.error },
  healthSuccess = { fg = groups.success },
  healthWarning = { fg = groups.warning },

  SnacksPickerCol = { fg = p.foreground, bg = p.color8, bold = true },
  SnacksPickerTitle = { fg = p.foreground, bg = p.color8, bold = true },
  SnacksPickerListCursorLine = { bg = brighten(p.color8, 6) },
  SnacksPickerMatch = { bg = p.color3, fg = p.color0 },
  SnacksPickerBorder = { fg = p.color8, bg = p.color8 },

  SnacksPicker = { link = "NormalFloat" },
  SnacksPickerPreview = { bg = brighten(p.color0, 3) },
  SnacksPickerFile = { fg = p.foreground },
  SnacksPickerDir = { fg = p.color7 },
  FloatBorder = { fg = groups.border, bg = "NONE" },
  FloatTitle = { fg = p.color10, bg = "NONE", bold = true },
  NormalFloat = { bg = p.color8, fg = p.foreground },
  SignColumn = { fg = p.foreground, bg = "NONE" },

  GitSignsAdd = { fg = groups.git_add, bg = "NONE" },
  GitSignsChange = { fg = groups.git_change, bg = "NONE" },
  GitSignsDelete = { fg = groups.git_delete, bg = "NONE" },
  SignAdd = { fg = groups.git_add, bg = "NONE" },
  SignChange = { fg = groups.git_change, bg = "NONE" },
  SignDelete = { fg = groups.git_delete, bg = "NONE" },

  FlashBackdrop = { bg = p.color0, fg = p.color7 },
  FlashMatch = { bg = p.color0, fg = p.color9 },
  FlashCurrent = { bg = p.color0, fg = p.color9 },
  FlashLabel = { bg = p.color0, fg = p.color2, bold = true },

  ["@field"] = { fg = p.foreground },
  ["@function"] = { fg = p.foreground },
  ["@method"] = { fg = p.color4 },
  ["@parameter"] = { fg = p.foreground, bold = true },
  ["@parameter.bash"] = { fg = p.foreground },
  ["@string.escape"] = { fg = p.color10 },
  ["@constructor"] = { fg = p.foreground },
  ["@attribute"] = { fg = p.foreground },
  ["@variable"] = { fg = p.foreground },
  ["@variable.builtin"] = { fg = p.foreground },
  ["@variable.member"] = { fg = p.foreground },
  ["@variable.parameter"] = { fg = p.foreground },
  ["@punctuation.special"] = { fg = p.foreground },
  ["@property.yaml"] = { fg = p.foreground },
}

for group, highlight in pairs(highlights) do
  vim.api.nvim_set_hl(0, group, highlight)
end
