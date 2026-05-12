vim.loader.enable()

require('globals')
_G.mia = require('mia')  -- opinionated conveniences
require('options')       -- global opts
require('packs')         -- plugins
require('session')       -- auto-managed

require('statusline')
require('tabline')
require('winbar')
require('wincolors')
require('fold')
