---@type LazySpec
return {
  { -- Colorscheme: catppuccin macchiato

    -- --------------------------------------------------------------------------
    -- Name        Latte      Frappe   **Macchiato   Mocha      Usage
    -- ----------- ---------- ---------- ----------- ---------- -----------------
    -- rosewater   #dc8a78    #f2d5cf    #f4dbd6     #f5e0dc    Winbar
    -- flamingo    #dd7878    #eebebe    #f0c6c6     #f2cdcd    Target word
    -- pink        #ea76cb    #f4b8e4    #f5bde6     #f5c2e7    Just pink
    -- mauve       #8839ef    #ca9ee6    #c6a0f6     #cba6f7    Tag
    -- red         #d20f39    #e78284    #ed8796     #f38ba8    Error
    -- maroon      #e64553    #ea999c    #ee99a0     #eba0ac    Lighter red
    -- peach       #fe640b    #ef9f76    #f5a97f     #fab387    Number
    -- yellow      #df8e1d    #e5c890    #eed49f     #f9e2af    Warning
    -- green       #40a02b    #a6d189    #a6da95     #a6e3a1    Diff add
    -- teal        #179299    #81c8be    #8bd5ca     #94e2d5    Hint
    -- sky         #04a5e5    #99d1db    #91d7e3     #89dceb    Operator
    -- sapphire    #209fb5    #85c1dc    #7dc4e4     #74c7ec    Constructor
    -- blue        #1e66f5    #8caaee    #8aadf4     #89b4fa    Diff changed
    -- lavender    #7287fd    #babbf1    #b7bdf8     #b4befe    CursorLine Nr
    -- text        #4c4f69    #c6d0f5    #cad3f5     #cdd6f4    Default fg
    -- subtext1    #5c5f77    #b5bfe2    #b8c0e0     #bac2de    Indicator
    -- subtext0    #6c6f85    #a5adce    #a5adcb     #a6adc8    Float title
    -- overlay2    #7c7f93    #949cbb    #939ab7     #9399b2    Popup fg
    -- overlay1    #8c8fa1    #838ba7    #8087a2     #7f849c    Conceal color
    -- overlay0    #9ca0b0    #737994    #6e738d     #6c7086    Fold color
    -- surface2    #acb0be    #626880    #5b6078     #585b70    Default comment
    -- surface1    #bcc0cc    #51576d    #494d64     #45475a    Darker comment
    -- surface0    #ccd0da    #414559    #363a4f     #313244    Darkest comment
    -- base        #eff1f5    #303446    #24273a     #1e1e2e    Default bg
    -- mantle      #e6e9ef    #292c3c    #1e2030     #181825    Darker bg
    -- crust       #dce0e8    #232634    #181926     #11111b    Darkest bg

    'catppuccin/nvim',
    name = 'catppuccin',
    ---@type CatppuccinOptions
    opts = {
      integrations = { snacks = true, notify = true },

      custom_highlights = function(colors)
        local util = require('catppuccin.utils.colors')
        local stl = {
          base = util.brighten(colors.base, 0.12),
          mantle = util.brighten(colors.mantle, 0.1),
          crust = util.brighten(colors.crust, 0.1),
          surface0 = util.darken(colors.surface0, 0.7, colors.base),
        }

        return {
          ['@field'] = { fg = colors.lavender },
          ['@dark'] = { fg = colors.surface0 },
          ['@boldconst'] = { fg = colors.peach, bold = true },

          ['@text.note'] = { fg = colors.mauve, bg = colors.none, bold = false },
          ['@text.todo'] = { fg = colors.yellow, bg = colors.none, bold = true },
          ['@text.danger'] = { fg = colors.maroon, bg = colors.none, bold = true },
          ['@text.warning'] = { fg = colors.peach, bg = colors.none, bold = true },

          ['@text.strong'] = { fg = colors.none },
          ['@text.emphasis'] = { fg = colors.none },
          ['@text.strike'] = { fg = colors.none },
          ['@text.uri'] = { style = { 'italic' } }, -- underline = false didn't work?

          -- ['@method'] = { link = '@lsp.type.method' },

          CommentSansItalic = { fg = colors.overlay0 },

          Folded = { fg = colors.blue, bg = colors.none },
          ColorColumn = { bg = stl.surface0 },

          Todo = { fg = colors.yellow, bg = colors.none, bold = true },

          TabLine = { fg = colors.surface2, bg = stl.mantle },
          TabLineSel = { fg = colors.lavender, bg = stl.mantle },
          TabLineNumber = { fg = colors.sapphire, bg = stl.mantle },
          TabLineFill = { fg = colors.surface2, bg = stl.mantle },
          TabLineWin = { fg = colors.mauve, bg = stl.mantle, bold = true },
          TabLineSelNumber = { fg = colors.red, bg = stl.mantle, bold = true },

          TabCopySel = { fg = colors.mauve, bg = stl.mantle, bold = true },
          TabLineRecording = { fg = colors.yellow, bg = stl.crust },
          TabLineSession = { fg = colors.pink, bg = stl.crust },

          -- from catppuccin group definition
          CursorLBase = { bg = util.darken(colors.surface0, 0.64, colors.base) },
          CursorLRecording = { bg = util.darken(colors.yellow, 0.15, colors.base) },
          CursorLine = { link = 'CursorLBase', force = true },

          StatusLine = { bg = stl.crust },
          stlModified = { fg = colors.red, bg = stl.crust },
          stlTypeInfo = { fg = colors.sky, bg = stl.crust },
          stlErrorInfo = { fg = colors.red, bg = stl.crust, bold = true },
          stlDescription = { fg = colors.blue, bg = stl.mantle },
          stlNodeTree = { fg = colors.overlay1, bg = stl.crust },

          stlNormalMode = { fg = colors.peach, bg = stl.base, bold = true },
          stlTerminalMode = { fg = colors.lavender, bg = stl.base, bold = true },
          stlInsertMode = { bg = colors.sky, fg = colors.base, bold = true },
          stlVisualMode = { bg = colors.yellow, fg = colors.base, bold = true },
          stlReplaceMode = { bg = colors.blue, fg = colors.base, bold = true },
          stlHover = { bg = stl.surface0, fg = colors.mauve, bold = true },

          FlashBackdrop = { link = 'CommentSansItalic' },

          FloatBorder = { link = 'WinSeparator', force = true },

          SnacksIndent = { fg = stl.surface0 },
          SnacksIndentScope = { fg = colors.surface1 },
        }
      end,
    },

    config = function(_, opts)
      if not vim.fn.has('vim_starting') then
        vim.cmd.highlight('clear')
      end

      -- stylua: ignore start
      local group_names = {
        'Comment', 'Constant', 'String', 'Character', 'Number', 'Boolean',
        'Float', 'Identifier', 'Function', 'Statement', 'Conditional', 'Repeat',
        'Label', 'Operator', 'Keyword', 'Exception', 'PreProc', 'Include',
        'Define', 'Macro', 'PreCondit', 'Type', 'StorageClass', 'Structure',
        'Typedef', 'Special', 'SpecialChar', 'Tag', 'Delimiter',
        'SpecialComment', 'Debug', 'Underlined', 'Ignore', 'Error', 'Todo',
      }
      -- stylua: ignore end

      -- Shouldn't this be done already? idk why it isn't
      for _, name in ipairs(group_names) do
        vim.api.nvim_set_hl(0, '@' .. name:lower(), { link = name, default = true })
      end

      require('catppuccin').setup(opts)
      require('catppuccin').load('macchiato')
    end,
  },
  { -- Glimmer: smooth animations yank, paste, undo, redo, etc
    'rachartier/tiny-glimmer.nvim',
    keys = { 'y', 'p', 'P' },
    opts = { overwrite = { auto_map = false } },
    config = function(_, opts)
      require('tiny-glimmer').setup(opts)
    end,
  },
  { -- mini.starter: startup menu
    'nvim-mini/mini.starter',
    lazy = vim.fn.argc() > 0,
    event = 'CmdlineEnter',
    config = function()
      local Starter = require('mini.starter')
      local cfgdir = vim.fn.stdpath('config')
      local items = {
        vim.iter(mia.session.get_sessinfo(true))
          :slice(1, 3)
          :map(function(s)
            return { action = 'Session load ' .. s.name, name = s.name, section = 'Sessions' }
          end)
          :totable(),

        Starter.sections.recent_files(3, true),
        Starter.sections.recent_files(3, false, true),

        { section = 'Pick',   name = 'Files',        action = 'Pick files' },
        { section = 'Pick',   name = 'Sessions',     action = 'Pick sessions' },
        { section = 'Pick',   name = 'Help tags',    action = 'Pick help' },
        { section = 'Pick',   name = 'Recent files', action = 'Pick recent' },
        { section = 'Pick',   name = 'Vim files',    action = 'Pick files cwd=' .. cfgdir },
        { section = 'Pick',   name = 'Dot files',    action = 'Pick config_files' },

        { section = 'Plugin', name = 'Pick',         action = 'Pick files cwd=' .. cfgdir .. '/lua/plugins' },
        { section = 'Plugin', name = 'Lazy',         action = 'Lazy' },
      }
      if mia.ide.enabled() then
        vim.list_extend(items, {
          { section = 'Plugin', name = 'Add new',     action = 'echo NYI' },
          { section = 'Plugin', name = 'Develop new', action = 'echo NYI' },
          { section = 'Plugin', name = 'Mason',       action = 'Mason' },
        })
      end
      table.insert(items, Starter.sections.builtin_actions())
      Starter.setup({ items = items, header = '', footer = '' })
    end,
  },
  { -- Highlight color codes like #ca9ee6, rgb(202,158,230), etc.
    'brenoprata10/nvim-highlight-colors',
    event = 'VeryLazy',
    opts = { enable_named_colors = false },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'TextChanged', 'SafeState' },
    opts = { attach_to_untracked = true },
  },
  { 'nvim-mini/mini.cursorword', event = 'VeryLazy', config = true },
  { 'rktjmp/lush.nvim',          lazy = true,        cmd = 'Lushify' },
}
