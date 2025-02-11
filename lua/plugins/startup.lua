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
        { action = 'Telescope find_files', name = 'Files', section = 'Telescope' },
        { action = 'Telescope help_tags', name = 'Help tags', section = 'Telescope' },
        { action = 'Telescope oldfiles', name = 'Recent files', section = 'Telescope' },
        { action = 'Telescope fd cwd=~/.config/nvim', name = 'Vim files', section = 'Telescope' },
        { action = 'Telescope config_files', name = 'Shell config files', section = 'Telescope' },
        Starter.sections.builtin_actions(),
      },
      header = '',
      footer = '',
    })
  end,
}
