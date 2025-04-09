return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,

  ---@module 'snacks'
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = { enabled = true, indent = { char = '╎' } },
    input = { enabled = true },
    notifier = {
      enabled = true,
      style = 'history',
      top_down = false,
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = false }, -- ??

    -- a lot of config, worth separation
    picker = require('config.snacks').picker_opts,
  },
  ctxmap = { require('config.snacks').ctxmap },
  keys = require('config.snacks').keys,
}
