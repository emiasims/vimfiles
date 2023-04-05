local lush = require 'lush'
local colors = require 'gruvbox.palette'

local red = colors.bright_red
local yellow = colors.bright_yellow
local blue = colors.bright_blue
local purple = colors.bright_purple
local aqua = colors.bright_aqua
local orange = colors.bright_orange

-- vim.api.nvim_set_hl(0, 'Sneak', { link = 'Error' })
-- vim.api.nvim_set_hl(0, 'SneakLabel', { link = 'Error' })
-- vim.api.nvim_set_hl(0, 'SneakScope', { link = 'Error' })

local gruvbox = require('gruvbox')

lush(lush.extends({ gruvbox }).with(function(injections)
  local sym = injections.sym
  return {
    sym('@variable')         { gruvbox.Identifier },
    sym('@pyKeyString')      { fg = blue.da(20) },
    sym('@variable.builtin') { gruvbox.Special },
    sym('@boldspecial')      { gruvbox.Special, gui = 'bold' },

    Sneak      { fg = yellow, gui = 'bold' },
    SneakLabel { fg = yellow, gui = 'bold' },
    SneakLabelMask { gruvbox.Special, gui = 'bold' },

    CursorWord0 { gui = 'underline' },
    CursorWord1 { gui = 'underline' },

    stlModified     { fg = red   , bg = gruvbox.StatusLine.bg },
    stlTypeInfo     { fg = aqua  , bg = gruvbox.StatusLine.bg },
    stlDirInfo      { fg = blue  , bg = gruvbox.StatusLine.bg.li(5) },
    stlErrorInfo    { fg = red   , bg = gruvbox.StatusLine.bg, gui = 'bold' },
    stlNormalMode   { fg = orange, bg = stlDirInfo.bg.li(5)  , gui = 'bold' },
    stlInsertMode   { bg = aqua  , fg = gruvbox.StatusLine.bg, gui = 'bold' },
    stlVisualMode   { bg = yellow, fg = gruvbox.StatusLine.bg, gui = 'bold' },
    stlReplaceMode  { bg = blue  , fg = gruvbox.StatusLine.bg, gui = 'bold' },
    stlTerminalMode { fg = purple, bg = stlNormalMode.bg     , gui = 'bold' },

    SneakScope { bg = orange, gui = 'bold' },
  }
end))

-- stylua: ignore
local group_names = {
  'Comment', 'Constant', 'String', 'Character', 'Number', 'Boolean', 'Float',
  'Identifier', 'Function', 'Statement', 'Conditional', 'Repeat', 'Label',
  'Operator', 'Keyword', 'Exception', 'PreProc', 'Include', 'Define', 'Macro',
  'PreCondit', 'Type', 'StorageClass', 'Structure', 'Typedef', 'Special',
  'SpecialChar', 'Tag', 'Delimiter', 'SpecialComment', 'Debug', 'Underlined',
  'Ignore', 'Error', 'Todo' }

-- Shouldn't this be done already? idk why it isn't
for _, name in ipairs(group_names) do
  vim.api.nvim_set_hl(0, '@' .. name:lower(), { link = name, default = true })
end
