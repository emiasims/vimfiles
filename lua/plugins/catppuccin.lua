return {
  "catppuccin/nvim",
  name = "catppuccin",
  event = 'CursorHold',
  lazy = false,
  opts = {
    integrations = { vim_sneak = true },

    custom_highlights = function(colors)

      local util = require("catppuccin.utils.colors")
      local stl = {
        base = util.brighten(colors.base, 0.12),
        mantle = util.brighten(colors.mantle, 0.1),
        crust = util.brighten(colors.crust, 0.1),
        surface0 = util.darken(colors.surface0, 0.7, colors.base),
      }

      return {
        ['@field'] = { fg = colors.lavender },
        ['@dark'] = { fg = colors.surface0 },

        Folded = { fg = colors.blue, bg = stl.crust },
        ColorColumn = { bg = stl.surface0 },

        Todo = { style = { 'bold', 'reverse' } },

        TabLine =          { fg = colors.surface2, bg = stl.mantle },
        TabLineSel =       { fg = colors.lavender, bg = stl.mantle },
        TabLineNumber =    { fg = colors.sapphire, bg = stl.mantle },
        TabLineFill =      { fg = colors.surface2, bg = stl.mantle },
        TabLineWin =       { fg = colors.mauve,    bg = stl.mantle, bold = true },
        TabLineSelNumber = { fg = colors.red,      bg = stl.mantle, bold = true },

        StatusLine =      { bg = stl.crust },
        stlModified =     { fg = colors.red,      bg = stl.crust },
        stlTypeInfo =     { fg = colors.sky,      bg = stl.crust },
        stlDirInfo =      { fg = colors.blue,     bg = stl.mantle },
        stlErrorInfo =    { fg = colors.red,      bg = stl.crust,   bold = true },
        stlNormalMode =   { fg = colors.peach,    bg = stl.base,    bold = true },
        stlTerminalMode = { fg = colors.lavender, bg = stl.base,    bold = true },
        stlInsertMode =   { bg = colors.sky,      fg = colors.base, bold = true },
        stlVisualMode =   { bg = colors.yellow,   fg = colors.base, bold = true },
        stlReplaceMode =  { bg = colors.blue,     fg = colors.base, bold = true },

      }
    end
  },

  config = function(config)
    vim.cmd.highlight 'clear'
    require('catppuccin').setup(config.opts)
    require('catppuccin').load('macchiato')
  end,
}
