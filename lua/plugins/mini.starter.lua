---@type LazySpec
return {
  'nvim-mini/mini.starter',
  lazy = vim.fn.argc() > 0,
  event = 'CmdlineEnter',
  config = function()
    local Starter = require('mini.starter')
    local cfgdir = vim.fn.stdpath('config')
    local session = require('session')
    local items = {
      vim
        .iter(session.get_sessinfo(true))
        :slice(1, 3)
        :map(function(s)
          return { action = 'Session load ' .. s.name, name = s.name, section = 'Sessions' }
        end)
        :totable(),

      Starter.sections.recent_files(3, true),
      Starter.sections.recent_files(3, false, true),

      { section = 'Pick', name = 'Files', action = 'Pick files' },
      { section = 'Pick', name = 'Sessions', action = 'Pick sessions' },
      { section = 'Pick', name = 'Help tags', action = 'Pick help' },
      { section = 'Pick', name = 'Recent files', action = 'Pick recent' },
      { section = 'Pick', name = 'Vim files', action = 'Pick files cwd=' .. cfgdir },
      { section = 'Pick', name = 'Dot files', action = 'Pick config_files' },

      { section = 'Plugin', name = 'Pick', action = 'Pick files cwd=' .. cfgdir .. '/lua/plugins' },
      { section = 'Plugin', name = 'Lazy', action = 'Lazy' },
    }
    if mia.ide.enabled() then
      vim.list_extend(items, {
        { section = 'Plugin', name = 'Add new', action = 'echo NYI' },
        { section = 'Plugin', name = 'Develop new', action = 'echo NYI' },
        { section = 'Plugin', name = 'Mason', action = 'Mason' },
      })
    end
    table.insert(items, Starter.sections.builtin_actions())
    Starter.setup({ items = items, header = '', footer = '' })
  end,
}
