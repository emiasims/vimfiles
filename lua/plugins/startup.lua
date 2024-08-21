---@type LazySpec
return {
  'echasnovski/mini.starter',
  config = function()
    local starter = require('mini.starter')
    starter.setup({
      items = {
        starter.sections.recent_files(3, true),
        starter.sections.recent_files(3, false, true),
        { action = 'Telescope find_files', name = 'Files', section = 'Telescope' },
        { action = 'Telescope help_tags', name = 'Help tags', section = 'Telescope' },
        { action = 'Telescope oldfiles', name = 'Recent files', section = 'Telescope' },
        { action = 'Telescope fd cwd=~/.config/nvim', name = 'Config files', section = 'Telescope' },
        starter.sections.builtin_actions(),
      },
      header = '',
      footer = '',
    })
  end,
}
