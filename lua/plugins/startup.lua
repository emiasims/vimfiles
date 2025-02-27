local Pick = function(name, opts)
  return function()
    return Snacks.picker[name](opts)
  end
end

---@type LazySpec
return {
  'echasnovski/mini.starter',
  enabled = true,
  lazy = vim.fn.argc() > 0,
  event = 'CmdlineEnter',
  config = function()
    local Starter = require('mini.starter')
    Starter.setup({
      items = {
        mia.session.mini_starter_items(3),
        Starter.sections.recent_files(3, true),
        Starter.sections.recent_files(3, false, true),
        { action = Pick('files'), name = 'Files', section = 'Pick' },
        { action = Pick('help'), name = 'Help tags', section = 'Pick' },
        { action = Pick('recent'), name = 'Recent files', section = 'Pick' },
        {
          action = Pick('files', { cwd = vim.fn.stdpath('config') }),
          name = 'Vim files',
          section = 'Pick',
        },
        { action = Pick('config_files'), name = 'Shell config files', section = 'Pick' },
        Starter.sections.builtin_actions(),
      },
      header = '',
      footer = '',
    })
  end,
}
