vim.loader.enable()
_G.mia = require('mia')

mia.load('plugin') -- loads all in mia/plugin
require('mia.lazy_init') -- plugins
mia.load('after')
