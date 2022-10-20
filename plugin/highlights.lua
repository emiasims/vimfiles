-- if package.loaded['gruvbox'] then
--   -- colors get wonky if I redo this
--   return
-- end

local lush = require 'lush'
local colors = require 'gruvbox.palette'

local red = colors.bright_red
local yellow = colors.bright_yellow
local blue = colors.bright_blue
local purple = colors.bright_purple
local aqua = colors.bright_aqua
local orange = colors.bright_orange

local gruvbox = require('gruvbox')

lush(lush.extends({ gruvbox }).with(function()
  return {
    stlModified     { fg = red   , bg = gruvbox.StatusLine.bg }      ,
    stlTypeInfo     { fg = aqua  , bg = gruvbox.StatusLine.bg }      ,
    stlDirInfo      { fg = blue  , bg = gruvbox.StatusLine.bg.li(5) },
    stlErrorInfo    { fg = red   , bg = gruvbox.StatusLine.bg        , gui = 'bold' },
    stlNormalMode   { fg = orange, bg = stlDirInfo.bg.li(5)          , gui = 'bold' },
    stlInsertMode   { bg = aqua  , fg = gruvbox.StatusLine.bg        , gui = 'bold' },
    stlVisualMode   { bg = yellow, fg = gruvbox.StatusLine.bg        , gui = 'bold' },
    stlReplaceMode  { bg = blue  , fg = gruvbox.StatusLine.bg        , gui = 'bold' },
    stlTerminalMode { fg = purple, bg = stlNormalMode.bg             , gui = 'bold' },
  }
end))
