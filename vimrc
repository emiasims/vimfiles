set history=10000
filetype plugin indent on
syntax on
set ttyfast
set encoding=utf-8
set nocompatible

set mouse=niv
set report=0
set hidden
set path=.,**
set virtualedit=block
set formatoptions=1crl
set nomodeline
if has('patch-7.3.541')
  set formatoptions+=j
endif
set updatetime=500
set winaltkeys=no
set pastetoggle=<F2>
set viewoptions=folds,cursor,slash,unix

set timeout ttimeout
set timeoutlen=300
set ttimeoutlen=250 " for key codes
set shell=bash

let $DATADIR=empty($XDG_DATA_HOME) ? $HOME.'/.local/share/vim' : $XDG_DATA_HOME.'/vim'
let &viewdir=$DATADIR.'/view'

call mkdir($DATADIR .. '/view', "p")
call mkdir($DATADIR .. '/tmp/backup', "p")
call mkdir($DATADIR .. '/tmp/swap', "p")
call mkdir($DATADIR .. '/tmp/undo', "p")

if exists('$SUDO_USER')
  set nowritebackup
else
  set backupdir=$DATADIR/tmp/backup
  set backupdir+=~/.backup
  set backup
  set backupext=.bak
  set directory=$DATADIR/tmp/swap//  " // necessary
  set directory+=.
  if has('persistent_undo')
    set undodir=$DATADIR/tmp/undo
    set undodir+=.
    set undofile
  endif
endif

set fileformats=unix,dos,mac
set history=10000
set noswapfile
set viminfo='300,<10,@50,h,n$DATADIR/viminfo

set textwidth=99
set softtabstop=2
set shiftwidth=2
set smarttab autoindent
set shiftround expandtab

set ignorecase smartcase infercase wildignorecase
set incsearch showmatch
set matchtime=3

set nowrap linebreak
set breakat=\ \	;:,!?
set nostartofline
set whichwrap+=[,]

set spellsuggest=best,10

set splitright
set switchbuf=useopen
set backspace=indent,eol,start
set diffopt=algorithm:histogram,filler,closeoff
set showfulltag
set completeopt=menuone
if has('patch-7.4.784')
  set completeopt+=noselect
  set completeopt+=noinsert
endif
if exists('+inccommand')
  set inccommand=nosplit
endif

set shortmess=aAoOTI
set scrolloff=4
set sidescrolloff=2
set number relativenumber
set lazyredraw
set showtabline=2
set pumheight=20
set cmdheight=2
set cmdwinheight=5
set laststatus=2

set showbreak=↘
set fillchars=vert:┃
set nojoinspaces
set wildmenu wildmode=longest:full,full

function! Tabline() abort
  let tabline = ''

  for i in range(1, tabpagenr('$'))
    let is_current_tab = (i == tabpagenr())
    let tabline ..= (is_current_tab ? '%#TabLineSel#' : '%*')

    let tabline ..= '%' .. i .. 'T ' .. i .. ' '

    let tab_buffers = tabpagebuflist(i)
    let active_win = tabpagewinnr(i)
    let tab_layout = []

    for j in range(len(tab_buffers))
      let bufnr = tab_buffers[j]
      let bname = bufname(bufnr)
      let bname = (bname != '' ? fnamemodify(bname, ':t') : '[No Name]')

      if is_current_tab && (j + 1) == active_win
        let bname = '%#TabLineWin#' .. bname .. (is_current_tab ? '%#TabLineSel#' : '%*')
      endif

      call add(tab_layout, bname)
    endfor

    let tabline ..= join(tab_layout, '|') .. ' '
  endfor

  let winnr = win_id2win(g:statusline_winid)
  let winbuf = '❬ :' .. winnr .. '  󰻾 :' .. g:statusline_winid .. '   :%n❭ '
  return tabline .. '%T%#TabLineFill#%=' .. winbuf
endfunction

function! Statusline() abort
  let mode = tolower(mode())
  if mode !~ '[nivrtc]'
    let mode = 'o'
  endif
  let mode_color = '%#StatusLineMode_' .. mode .. '#'
  let digits = float2nr(ceil(log10(line('$') + 1)))
  let width = '%' .. digits .. '.' .. digits

  return mode_color .. ' ' .. mode .. ' %*'
        \ .. ' %h%q%f%* '
        \ .. '%#StatusLineModified#%m%*%='
        \ .. '%#StatusLineTypeInfo#%y%* '
        \ .. mode_color .. ' %2p%% ☰ ' .. width .. 'l/' .. width .. 'L : %02c %* '
endfunction

set tabline=%!Tabline()
set statusline=%!Statusline()

colorscheme evolution

if has('patch-7.4.1570')
  set shortmess+=c
  set shortmess+=F
endif

if has('conceal') && v:version >= 703
  set conceallevel=2
endif
