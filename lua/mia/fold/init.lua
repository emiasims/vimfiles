vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.mia.foldexpr(v:lnum)'
vim.o.foldtext = 'v:lua.mia.foldtext()'

require 'mia.fold.hue'
require('foldhue').enable()
