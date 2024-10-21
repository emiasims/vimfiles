_G.mia = require('mia')

mia.require('global')

mia.load('plugin') -- loads all in that dir
require('mia.lazy_init') -- plugins
mia.load('after')
