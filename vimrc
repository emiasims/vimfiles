set history=10000
filetype plugin indent on
syntax on
set ttyfast
set encoding=utf-8
set nocompatible

let $DATADIR=empty($XDG_DATA_HOME) ? $HOME.'/.local/share/vim' : $XDG_DATA_HOME.'/vim'
let &viewdir=$DATADIR.'/view'

" Settings: {{{1
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

call mkdir($DATADIR .. '/view', "p")
call mkdir($HOME .. '/.backup', "p")
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
if has('nvim')
  if exists('$SUDO_USER') | set shada= | endif
  set shada='300,<10,@50,s100,h
else
  set viminfo='300,<10,@50,h,n$DATADIR/viminfo
endif

set textwidth=99
set softtabstop=2
set shiftwidth=2
set smarttab
set autoindent
set shiftround
set expandtab

set ignorecase
set smartcase
set infercase
set wildignorecase
set incsearch
set showmatch
set matchtime=3

set nowrap
set linebreak
set breakat=\ \	;:,!?
set nostartofline
set whichwrap+=[,]

set spellsuggest=best,10

" Save when exiting a buffer/window. Saving on idle is a bit too aggressive for me.
set autowriteall
augroup vimrc_writeall
  autocmd!
  autocmd WinLeave,FocusLost * ++nested if &modifiable && filereadable(expand('%')) | update | endif
augroup END

if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  " let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " let g:ctrlp_use_caching = 0
endif

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
set number
set relativenumber
set lazyredraw
set showtabline=2
set pumheight=20
set cmdheight=2
set cmdwinheight=5
set laststatus=2
set colorcolumn=80
set cursorline
set signcolumn=yes

set list
set listchars=nbsp:⊗
set listchars+=tab:▷‒
set listchars+=extends:»
set listchars+=precedes:«
set listchars+=trail:•
set showbreak=↘
set fillchars=vert:┃
set nojoinspaces
set wildmenu wildmode=longest:full,full

if has('termguicolors')
  set termguicolors
  if !has('nvim')
    let &t_8f = "\<Esc>[38:2:%lu:%lu:%lum"
    let &t_8b = "\<Esc>[48:2:%lu:%lu:%lum"
  endif
endif

" Lush colorscheming
if !has('nvim')
  colorscheme evolution
endif

if has('patch-7.4.1570')
  set shortmess+=c
  set shortmess+=F
endif

if has('conceal') && v:version >= 703
  set conceallevel=2
endif

if has('folding')
  set foldmethod=syntax
  set foldlevelstart=99
  set foldnestmax=3
endif
set foldtext=fold#text()

" Windows {{{2
if has('win32')
  function! s:setup_guifont() abort
    Guifont! DejaVu Sans Mono:h9
  endfunction
  call defer#onidle('call s:setup_guifont()')
endif
