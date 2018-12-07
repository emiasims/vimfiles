set history=10000
filetype plugin indent on
syntax on

let $DATADIR=empty($XDG_DATA_HOME) ? $HOME.'/.local/share/vim' : $XDG_DATA_HOME.'/vim'
let &viewdir=$DATADIR.'/view'

runtime settings.vim
runtime plugins.vim
" vim: set ts=2 sw=2 tw=99 noet :
