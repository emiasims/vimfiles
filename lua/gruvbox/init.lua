local lush = require("lush")
local hsl = lush.hsl

-- Original colorscheme from: https://github.com/gruvbox-community/gruvbox
-- Lush variant from:         https://github.com/npxbr/gruvbox.nvim

local colors = {
  dark0_hard     = hsl(195, 6, 12),
  dark0          = hsl(0, 0, 15),
  dark0_soft     = hsl(20, 3, 19),
  dark1          = hsl(20, 5, 20),
  dark2          = hsl(22, 7, 27),
  dark3          = hsl(27, 10, 36),
  dark4          = hsl(28, 11, 44),
  light0_hard    = hsl(53, 74, 91),
  light0         = hsl(48, 87, 87),
  light0_soft    = hsl(46, 67, 84),
  light1         = hsl(43, 59, 81),
  light2         = hsl(40, 38, 73),
  light3         = hsl(39, 24, 66),
  light4         = hsl(35, 17, 59),
  bright_orange  = hsl(27, 99, 55),
  neutral_orange = hsl(24, 88, 45),
  faded_orange   = hsl(19, 97, 35),
  bright_red     = hsl(6, 96, 59),
  neutral_red    = hsl(2, 75, 46),
  faded_red      = hsl(358, 100, 31),
  -- bright_green   = hsl(61, 66, 44),
  -- neutral_green  = hsl(60, 71, 35),
  -- faded_green    = hsl(57, 79, 26),
  bright_green   = hsl(96, 50, 44),
  neutral_green  = hsl(95, 71, 35),
  faded_green    = hsl(92, 79, 26),
  bright_purple  = hsl(344, 47, 68),
  neutral_purple = hsl(333, 34, 54),
  faded_purple   = hsl(323, 39, 40),
  bright_yellow  = hsl(42, 95, 58),
  neutral_yellow = hsl(40, 73, 49),
  faded_yellow   = hsl(37, 80, 39),
  bright_blue    = hsl(157, 16, 58),
  neutral_blue   = hsl(183, 33, 40),
  faded_blue     = hsl(190, 89, 25),
  bright_aqua    = hsl(104, 35, 62),
  neutral_aqua   = hsl(122, 21, 51),
  faded_aqua     = hsl(143, 30, 37),
  gray           = hsl(30, 12, 51),
}

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
local purple = colors.bright_purple
local aqua = colors.bright_aqua
local orange = colors.bright_orange
local gray = colors.gray
local sign_column = bg1

-- set colors_name var
vim.g.colors_name = "gruvbox"

-- handle light/dark contrast settings
local bg = vim.o.background
if bg == nil then
  bg = "dark"
  vim.o.background = bg
end

-- swap colors if light mode
if bg == "light" then
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

-- neovim terminal mode colors
vim.g.terminal_color_0 = tostring(bg0)
vim.g.terminal_color_8 = tostring(gray)
vim.g.terminal_color_1 = tostring(colors.neutral_red)
vim.g.terminal_color_2 = tostring(red)
vim.g.terminal_color_10 = tostring(green)
vim.g.terminal_color_3 = tostring(colors.neutral_yellow)
vim.g.terminal_color_11 = tostring(yellow)
vim.g.terminal_color_4 = tostring(colors.neutral_blue)
vim.g.terminal_color_12 = tostring(blue)
vim.g.terminal_color_5 = tostring(colors.neutral_purple)
vim.g.terminal_color_13 = tostring(purple)
vim.g.terminal_color_6 = tostring(colors.neutral_aqua)
vim.g.terminal_color_14 = tostring(aqua)
vim.g.terminal_color_7 = tostring(fg4)
vim.g.terminal_color_15 = tostring(fg1)


local groups = lush(function()
  return {

    Conceal      { fg = bg2 },
    ColorColumn  { bg = bg1 },
    CursorLine   { bg = bg1 },
    CursorColumn { CursorLine },

    Directory    { fg = red, gui = 'bold' },
    DiffAdd      { fg = green },
    DiffChange   { fg = aqua },
    DiffDelete   { fg = red },
    DiffText     { fg = yellow },

    VertSplit    { fg = bg0.li(4) },
    Folded       { fg = gray, bg = bg1 },
    FoldColumn   { fg = gray, bg = bg1 },
    SignColumn   { bg = bg0 },

    ErrorMsg     { fg = bg0, bg = red, gui = 'bold' },
    Search       { bg = bg1.li(6), gui = 'bold' },
    IncSearch    { bg = bg3, gui = 'bold,inverse' },

    LineNr       { fg = bg4 },
    CursorLineNr { fg = yellow },
    ModeMsg      { fg = yellow, gui = 'bold' },
    MoreMsg      { fg = yellow, gui = 'bold' },
    MatchParen   { fg = orange, gui = 'bold' },

    NonText      { fg = bg2 },
    Normal       { fg = fg1, bg = bg0 },
    NormalFloat  { Normal },
    -- NormalNC     { fg = Normal.fg, bg = Normal.bg.li(5) },
    Pmenu        { fg = fg1, bg = bg1 },
    PmenuSel     { fg = blue, bg = bg1.li(4), gui = 'bold' },
    PmenuSbar    { bg = bg2 },
    PmenuThumb   { bg = bg4 },

    Question     { fg = orange, gui = 'bold' },
    QuickFixLine { bg = bg1 },
    SpecialKey   { fg = fg4 },
    SpellRare    { fg = purple, gui = 'underline' },
    SpellBad     { fg = red, gui = 'underline' },

    StatusLine   { fg = fg1  , bg = VertSplit.fg },
    StatusLineNC { fg = fg4  , bg = VertSplit.fg },
    TabLineFill  { fg = bg4  , bg = bg1 }      ,
    TabLine      { fg = bg4  , bg = bg1 }      ,
    TabLineSel   { fg = green, bg = bg1 }      ,

    TabLineWin       { fg = blue , bg = StatusLine.bg  , gui = 'bold' },
    TabLineNumber    { fg = green, bg = StatusLine.bg },
    TabLineSelNumber { fg = red  , bg = StatusLine.bg  , gui = 'bold' },

    stlModified  { fg = red  , bg = StatusLine.bg },
    stlTypeInfo  { fg = aqua , bg = StatusLine.bg },
    stlDirInfo   { fg = blue , bg = StatusLine.bg.li(5) },
    stlErrorInfo { fg = red  , bg = StatusLine.bg },

    stlNormalMode   { fg = orange, bg = stlDirInfo.bg.li(5), gui = 'bold' },
    stlInsertMode   { bg = aqua  , fg = StatusLine.bg      , gui = 'bold' },
    stlVisualMode   { bg = yellow, fg = StatusLine.bg      , gui = 'bold' },
    stlReplaceMode  { bg = blue  , fg = StatusLine.bg      , gui = 'bold' },
    stlTerminalMode { fg = purple, bg = stlNormalMode.bg   , gui = 'bold' },

    Visual         { bg = bg1.li(3) },
    VisualNOS      { Visual },
    WarningMsg     { fg = red, gui = 'bold' },
    WildMenu       { fg = blue, bg = bg2, gui = 'bold' },

    Constant       { fg = purple },
    String         { fg = green },
    Character      { Constant },
    Number         { Constant },
    Boolean        { Constant },
    Float          { Constant },

    Identifier     { fg = blue },
    Function       { fg = green },
    -- Function       { fg = green, gui = 'bold' },

    Statement      { fg = red },
    Conditional    { Statement },
    Repeat         { Statement },
    Label          { Statement },
    Operator       { fg = Normal.fg },
    Exception      { Statement },
    Keyword        { fg = aqua },

    PreProc        { fg = aqua },
    Include        { PreProc },
    Define         { PreProc },
    Macro          { PreProc },
    PreCondit      { PreProc },

    Type           { fg = yellow },
    StorageClass   { fg = orange },
    Structure      { fg = aqua },
    Typedef        { fg = yellow },

    Special        {},
    SpecialChar    { fg = red },
    Tag            { fg = aqua, gui = 'bold' },
    Delimiter      { fg = fg2 },
    Comment        { fg = gray },
    SpecialComment { Comment },
    Debug          { fg = red },
    Underlined     { gui = 'underline' },
    Bold           { gui = 'bold' },
    Italic         { gui = 'italic' },

    Ignore         {},
    Error          { fg = red, gui = 'bold' },
    Todo           { fg = orange, gui = 'bold' },

    Title          { Identifier },

    -- My settings
    -- vim-signify
    SignifySignAdd    { fg = green },
    SignifySignChange { fg = aqua },
    SignifySignDelete { fg = red },

    orgHeadline1 { fg = blue, gui = 'bold' },
    orgHeadline2 { fg = aqua },
    orgHeadline3 { fg = purple.ro(-40).de(20) },
    orgHeadline4 { fg = green },
    orgHeadline5 { orgHeadline2 },
    orgHeadline6 { orgHeadline3 },
    orgHeadline7 { orgHeadline4 },
    orgHeadline8 { orgHeadline2 },
    orgHeadline9 { orgHeadline3 },
    orgHeadlineN { orgHeadline4 },

    orgHeadlineInnerStar { Comment },
    orgHeadlineLastStar  { Constant },
    orgTodo              { Todo },
    orgDone              { fg = blue.da(20) },
    orgHeadlinePriority  { Error },
    orgHeadlineTags      { fg=Normal.fg },

    orgPlanDeadline      { Comment },
    orgPlanScheduled     { Comment },
    orgPlanClosed        { Comment },
    orgPlanTime          { Comment },
    orgPlanning          { Comment },
    orgDate              { Comment },
    orgTime              { Comment },
    orgTimeRepeat        { Comment },
    orgTimeDelay         { Comment },
    orgTimestampElements { Comment },
    orgListLeader        { Constant },
    orgListCheck         { Todo },
    orgListTag           { Comment },

    orgNodeProperty       { fg = Constant.fg.de(40).da(10) },
    orgNodeMultiProperty  { orgNodeProperty },
    orgPropertyDrawerEnds { Comment },
    orgPropertyName       { PreProc },
    orgURI                { Comment },
    orgLinkEnds           { Conceal },
    orgLinkDescription    { Tag },
    orgSetting            { Error },
    orgSettingEnds        { Comment },
    orgSettingName        { Todo },
    orgSettingArguments   { Comment },
    orgComment            { Comment },
    orgVerbatim           { fg = Normal.fg },

    Sneak      { fg = yellow, gui = 'bold' },
    SneakLabel { fg = yellow, gui = 'bold' },

    CursorWord0 { gui = 'underline' },
    CursorWord1 { gui = 'underline' },

  }
end)

-- returns a parsed spec, can be `lush.compile`d
return groups
