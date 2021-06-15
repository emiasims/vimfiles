
-- FIXME This is old and dumb. Change it
vim.cmd([[
let g:defaultdir=has('win32') ? $HOME.'\AppData\Local\nvim' : $HOME.'/.config/nvim'
let $CFGDIR=empty($XDG_CONFIG_HOME) ? g:defaultdir : $XDG_CONFIG_HOME.'/nvim'

let g:defaultdir=has('win32') ? $HOME.'\AppData\Local\nvim-data' : $HOME.'/.local/share/vim'
let $DATADIR=empty($XDG_DATA_HOME) ? g:defaultdir : $XDG_DATA_HOME.'/nvim'
unlet! g:defaultdir
]])

vim.cmd('runtime settings.vim')

require 'mia.plugin'
require 'mia.tslib'
require 'mia.utils'
require ('lush')(require('gruvbox'))

fold = require('mia.tslib.fold').queryexpr
