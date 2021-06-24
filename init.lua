require 'mia.utils' -- Sets up globals: requireas, reload, and P

vim.env.CFGDIR = (vim.env.XDG_CONFIG_HOME or vim.env.HOME)..'/.config/nvim'
vim.env.DATADIR = (vim.env.XDG_DATA_HOME or vim.env.HOME)..'/.local/share/nvim'
vim.cmd('runtime settings.vim')

require 'mia.plugin'

-- This is like the following, see lua/mia/utils.lua, sets up for reloading
-- fold = require('mia.tslib.fold').queryexpr
requireas('tsfold', 'mia.tslib.fold', 'queryexpr')
