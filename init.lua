vim.loader.enable()

require('globals')
_G.mia = require('mia')

require('options')

-- install lazy.nvim pack
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.pack.add({ 'https://github.com/folke/lazy.nvim.git' }, { confirm = false })
  vim.fn.rename(vim.fn.stdpath('data') .. '/site/pack/core/opt/lazy.nvim', lazypath)
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { import = 'plugins' },
  change_detection = { notify = false },
  rocks = { enabled = false },
  dev = { path = vim.fn.stdpath('config') .. '/mia_plugins' },
  ui = { border = 'rounded' },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        'rplugin',
      },
    },
  },
})

-- auto tracking
require('session')

-- set up UI
require('statusline')
require('tabline')
require('winbar')
require('wincolors')
require('fold')
