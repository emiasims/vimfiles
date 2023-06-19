local lush = require 'lush'
local hsl = lush.hsl

-- Original colorscheme from: https://github.com/gruvbox-community/gruvbox
-- Lush variant from:         https://github.com/npxbr/gruvbox.nvim

local colors = require 'gruvbox.palette'

-- options (dark mode by default)
local bg0 = colors.dark0
local bg1 = colors.dark1
local bg2 = colors.dark2
local bg3 = colors.dark3
local bg4 = colors.dark4

local fg0 = colors.light0
local fg1 = colors.light1
local fg2 = colors.light2
local fg3 = colors.light3
local fg4 = colors.light4

local red = colors.bright_red
local green = colors.bright_green
local yellow = colors.bright_yellow
local blue = colors.bright_blue
local pear = colors.neutral_pear
local purple = colors.bright_purple
local aqua = colors.bright_aqua
local orange = colors.bright_orange
local gray = colors.gray
local sign_column = bg1

-- set colors_name var
-- vim.g.colors_name = "gruvbox"

-- handle light/dark contrast settings
local bg = vim.o.background
if bg == nil then
  bg = 'dark'
  vim.o.background = bg
end

-- swap colors if light mode
if bg == 'light' then
  bg0 = colors.light0
  bg1 = colors.light1
  bg2 = colors.light2
  bg3 = colors.light3
  bg4 = colors.light4
  fg0 = colors.dark0
  fg1 = colors.dark1
  fg2 = colors.dark2
  fg3 = colors.dark3
  fg4 = colors.dark4
  red = colors.faded_red
  green = colors.faded_green
  yellow = colors.faded_yellow
  blue = colors.faded_blue
  purple = colors.faded_purple
  aqua = colors.faded_aqua
  orange = colors.faded_orange
end

-- -- neovim terminal mode colors --- I prefer not modifying them
-- vim.g.terminal_color_0 = tostring(bg0) ...

local groups = lush(function(injections)
  local sym = injections.sym
  return {

    Conceal { fg = bg2 },
    ColorColumn { bg = bg1 },
    CursorLine { bg = bg1 },
    CursorColumn { CursorLine },

    Directory { fg = red, gui = 'bold' },
    DiffAdd { fg = green },
    DiffChange { fg = aqua },
    DiffDelete { fg = red },
    DiffText { fg = yellow },

    VertSplit { fg = bg0.li(4) },
    Folded { fg = gray },
    -- Folded       { fg = gray, bg = bg1 },
    FoldColumn { fg = gray, bg = bg1 },
    SignColumn { bg = bg0 },

    ErrorMsg { fg = bg0, bg = red, gui = 'bold' },
    Search { bg = bg1.li(6), gui = 'bold' },
    IncSearch { bg = bg3, gui = 'bold,inverse' },

    LineNr { fg = bg4 },
    CursorLineNr { fg = yellow },
    ModeMsg { fg = yellow, gui = 'bold' },
    MoreMsg { fg = yellow, gui = 'bold' },
    MatchParen { fg = orange, gui = 'bold' },

    NonText { fg = bg2 },
    Normal { fg = fg1, bg = bg0 },
    NormalFloat { Normal },
    -- NormalNC     { fg = Normal.fg, bg = Normal.bg.li(5) },
    Pmenu { fg = fg1, bg = bg1 },
    PmenuSel { fg = blue, bg = bg1.li(4), gui = 'bold' },
    PmenuSbar { bg = bg2 },
    PmenuThumb { bg = bg4 },

    Question { fg = orange, gui = 'bold' },
    QuickFixLine { bg = bg1 },
    SpecialKey { fg = fg4 },
    SpellRare { fg = purple, gui = 'underline' },
    SpellBad { fg = red, gui = 'underline' },

    StatusLine { fg = fg1, bg = VertSplit.fg },
    StatusLineNC { fg = fg4, bg = VertSplit.fg },
    TabLineFill { fg = bg4, bg = bg1 },
    TabLine { fg = bg4, bg = bg1 },
    TabLineSel { fg = green, bg = bg1 },

    TabLineWin { fg = blue, bg = StatusLine.bg, gui = 'bold' },
    TabLineNumber { fg = green, bg = StatusLine.bg },
    TabLineSelNumber { fg = red, bg = StatusLine.bg, gui = 'bold' },

    Visual { bg = bg1.li(3) },
    VisualNOS { Visual },
    WarningMsg { fg = red, gui = 'bold' },
    WildMenu { fg = blue, bg = bg2, gui = 'bold' },

    Constant { fg = purple },
    String { fg = colors.neutral_aqua },
    Character { Constant },
    Number { Constant },
    Boolean { Constant },
    Float { Constant },

    Identifier { fg = blue },
    Function { fg = green },
    -- Function       { fg = green, gui = 'bold' },

    Statement { fg = red },
    Conditional { Statement },
    Repeat { Statement },
    Label { Statement },
    Operator { fg = Normal.fg },
    Exception { Statement },
    Keyword { fg = aqua },

    PreProc { fg = aqua },
    Include { PreProc },
    Define { PreProc },
    Macro { PreProc },
    PreCondit { PreProc },

    Type { fg = yellow },
    StorageClass { fg = orange },
    Structure { fg = aqua },
    Typedef { fg = yellow },

    Special { fg = orange },
    SpecialChar { fg = red },
    Tag { fg = aqua, gui = 'bold' },
    Delimiter { fg = fg2 },
    Comment { fg = gray },
    SpecialComment { Type },
    Debug { fg = red },
    Verbatim { Comment },
    Code { fg = fg4, bg = bg1, gui = 'bold' },
    Underline { gui = 'underline' },
    Underlined { gui = 'underline' },
    Undercurl { gui = 'undercurl' },
    Bold { gui = 'bold' },
    Italic { gui = 'italic' },
    Strikethrough { gui = 'strikethrough' },

    Ignore {},
    Error { fg = red, gui = 'bold' },
    Todo { fg = orange, gui = 'bold' },

    Title { Identifier },

  }
end)

-- returns a parsed spec, can be `lush.compile`d
return groups
