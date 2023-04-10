return {
  'folke/tokyonight.nvim',
  config = function() require('tokyonight').setup {
      on_highlights = function(hl, colors)

        hl.Folded.bg = hl.CursorLine.bg

        hl.TabLine =          { fg = colors.dark3,   bg = hl.TabLine.bg }
        hl.TabLineWin =       { fg = colors.green,   bg = hl.TabLine.bg, bold = true }
        hl.TabLineSel =       { fg = colors.blue,    bg = hl.TabLine.bg }
        hl.TabLineSelNumber = { fg = colors.magenta, bg = hl.TabLine.bg, bold = true }
        hl.TabLineNumber =    { fg = colors.green,   bg = hl.TabLine.bg }
        hl.TabLineFill =      { fg = colors.dark3,   bg = hl.TabLine.bg }

        hl.stlModified =     { fg = colors.red,    bg = hl.StatusLine.bg }
        hl.stlTypeInfo =     { fg = colors.aqua,   bg = hl.StatusLine.bg }
        hl.stlDirInfo =      { fg = colors.blue,   bg = hl.StatusLine.bg }
        hl.stlErrorInfo =    { fg = colors.red,    bg = hl.StatusLine.bg, bold = true }
        hl.stlNormalMode =   { fg = colors.orange, bg = hl.StatusLine.bg, bold = true }
        hl.stlInsertMode =   { bg = colors.cyan,   fg = hl.StatusLine.bg, bold = true }
        hl.stlVisualMode =   { bg = colors.yellow, fg = hl.StatusLine.bg, bold = true }
        hl.stlReplaceMode =  { bg = colors.blue,   fg = hl.StatusLine.bg, bold = true }
        hl.stlTerminalMode = { fg = colors.purple, bg = hl.StatusLine.bg, bold = true }

      end,
    }

    vim.cmd 'colorscheme tokyonight'
  end

}

--  day = <1>{
--    bg = "#1a1b26",
--    bg_dark = "#16161e"
--  },
--  default = {
--    bg = "#24283b",
--    bg_dark = "#1f2335",
--    bg_highlight = "#292e42",
--    blue = "#7aa2f7", blue0 = "#3d59a1", blue1 = "#2ac3de", blue2 = "#0db9d7",
--    blue5 = "#89ddff", blue6 = "#b4f9f8", blue7 = "#394b70",
--    comment = "#565f89",
--    cyan = "#7dcfff",
--    dark3 = "#545c7e",
--    dark5 = "#737aa2",
--    fg = "#c0caf5", fg_dark = "#a9b1d6", fg_gutter = "#3b4261",
--    git = { add = "#4197a4", change = "#506d9c", delete = "#c47981", ignore = "#545c7e" },
--    gitSigns = { add = "#399a96", change = "#6482bd", delete = "#c25d64" },
--    green = "#9ece6a", green1 = "#73daca", green2 = "#41a6b5",
--    magenta = "#bb9af7", magenta2 = "#ff007c",
--    none = "NONE",
--    orange = "#ff9e64", purple = "#9d7cd8",
--    red = "#f7768e", red1 = "#db4b4b", teal = "#1abc9c",
--    terminal_black = "#414868",
--    yellow = "#e0af68"
--  },
