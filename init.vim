let s:defaultdir=has('win32') ? $HOME.'\AppData\Local\nvim' : $HOME.'/.config/nvim'
let $CFGDIR=empty($XDG_CONFIG_HOME) ? s:defaultdir : $XDG_CONFIG_HOME.'/nvim'

let s:defaultdir=has('win32') ? $HOME.'\AppData\Local\nvim-data' : $HOME.'/.local/share/vim'
let $DATADIR=empty($XDG_DATA_HOME) ? s:defaultdir : $XDG_DATA_HOME.'/vim'

runtime settings.vim
runtime plugins.vim

" vim: set ts=2 sw=2 tw=99 et :
