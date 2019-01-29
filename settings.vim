if has ('vim_starting')
  set encoding=utf-8
endif

scriptencoding utf-8
" Note: Settings only wrapped with an 'if has...' if it
" has caused an issue on one of the systems I vim on.
" Settings:
" General: {{{
set mouse=niv
set modeline
set report=0
set hidden
set path=.,**
set virtualedit=block
set formatoptions=1crl
set autoread
if has('patch-7.3.541')
  set formatoptions+=j
endif
set ttyfast
set updatetime=500
set winaltkeys=no
set pastetoggle=<F2>
set viewoptions=folds,cursor,slash,unix

if has('clipboard')
  set clipboard+=unnamedplus
endif

" " TODO: get working over ssh!
" function! Osc52Yank() abort
"   let l:buffer=system('base64 -w0', @")
"   let l:buffer=substitute(l:buffer, "\n$", "", "")
"   let l:buffer='\e]52;c;'.l:buffer.'\x07'
"   silent exe "!echo -ne ".shellescape(l:buffer)." > $SSH_TTY"
" endfunction
" command! Osc52CopyYank call Osc52Yank()
" augroup Example
"   autocmd!
"   autocmd TextYankPost * if v:event.operator ==# 'y' | call Osc52Yank() | endif
" augroup END

set timeout ttimeout
set timeoutlen=750  " Time out on mappings
set ttimeoutlen=250 " for key codes
" }}}
" Backup, Swap, Undo, History: {{{
if exists('$SUDO_USER')
  set nowritebackup
  set noswapfile
else
  set backupdir=$DATADIR/tmp/backup
  set backupdir+=.
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
if has('nvim')
  if exists('$SUDO_USER') | set shada= | endif
  set shada='300,<10,@50,s100,h
else
  set viminfo='300,<10,@50,h,n$DATADIR/viminfo
endif
" }}}
" Tabs and Indents: {{{
set textwidth=99
set softtabstop=2
set shiftwidth=2
set smarttab
set autoindent
set shiftround
" }}}
" Searching: {{{
set ignorecase
set smartcase
set infercase
set incsearch
set showmatch
set matchtime=3
" }}}
" Behavior: {{{
set nowrap
set linebreak
set breakat=\ \	;:,!?
set nostartofline
set whichwrap+=[,]

" Save when exiting a buffer/window. Saving on idle is too aggressive for me.
set autowriteall
augroup vimrc_writeall
  autocmd!
  autocmd WinLeave * if &modifiable && &modified && filereadable(expand('%')) | write | endif
augroup END

set splitright
set switchbuf=useopen,usetab
set backspace=indent,eol,start
set diffopt=filler,iwhite
set showfulltag
set completeopt=menuone
if has('patch-7.4.784')
  set completeopt+=noselect
  set completeopt+=noinsert
endif
if exists('+inccommand')
  set inccommand=nosplit
endif
" }}}
" UI: {{{
set noshowmode
set shortmess=aAoOTI
set scrolloff=4
set sidescrolloff=2
set number
set relativenumber
set lazyredraw
set showtabline=2
set pumheight=20
set showcmd
set cmdheight=2
set cmdwinheight=5
set laststatus=2
set colorcolumn=80
set cursorline
set display=lastline

set list
set listchars=nbsp:⊗
set listchars+=tab:▷‒
set listchars+=extends:»
set listchars+=precedes:«
set listchars+=trail:•
set showbreak=↘
set fillchars=vert:┃
set nojoinspaces

set wildmenu
set wildmode=longest:full,full

if has('termguicolors')
  set termguicolors
elseif match($TERM, 256) >= 0
  set t_Co=256
endif
colorscheme evolution

if has('patch-7.4.1570')
  set shortmess+=c
  set shortmess+=F
endif

if has('conceal') && v:version >= 703
  set conceallevel=2
endif
" }}}
" Folds: {{{
if has('folding')
  set foldmethod=syntax
  set foldlevelstart=99
endif
set foldtext=fold#text()
" }}}
" Plugin setup: {{{
if has('packages')
  set packpath+=$CFGDIR
endif
let g:python_highlight_all = 1
" }}}

" Autocommands:
" General: {{{
augroup vimrc_general
  autocmd!
  au BufWinLeave ?* if empty(&buftype) | mkview | endif
  au BufWinEnter ?* if empty(&buftype) | silent! loadview | endif

  autocmd WinEnter,FocusGained * checktime

  " Update filetype on save if empty
  autocmd BufWritePost * nested
        \ if &l:filetype ==# '' || exists('b:ftdetect')
        \ |   unlet! b:ftdetect
        \ |   filetype detect
        \ | endif

  " When editing a file, always jump to the last known cursor position, if valid.
  autocmd BufReadPost *
        \ if &ft !~ '^git\c' && ! &diff && line("'\"") > 0 && line("'\"") <= line("$")
        \|   execute 'normal! g`"zvzz'
        \| endif

  " Disable paste and/or update diff when leaving insert mode
  autocmd InsertLeave * if &paste | setlocal nopaste | echo 'nopaste' | endif
  autocmd InsertLeave * if &l:diff | diffupdate | endif

  " TODO: save values
  autocmd WinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline

augroup END
" }}}
" Filetype: {{{
augroup vimrc_filetype
  autocmd!
  if has('nvim')
    autocmd FileType help setlocal nu rnu signcolumn=no
  endif
  autocmd FileType qfreplace setlocal nofoldenable
  autocmd BufNewFile,BufRead *.yapf set filetype=cfg
  autocmd FileType sh let g:is_bash=1
  autocmd FileType sh let g:sh_fold_enabled=5
  autocmd BufRead * if empty(&filetype) | set commentstring=#%s | endif
augroup END    " vimrc_filetype
" }}}
" Numbertoggle: {{{
" -------------
augroup vimrc_numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END
" }}}

" Mappings:
" Simple: {{{
nnoremap <Space> <nop>
xnoremap <Space> <nop>

nnoremap <Up>    <nop>
nnoremap <Down>  <nop>
nnoremap <Left>  <nop>
nnoremap <Right> <nop>

let g:mapleader=' '
let g:maplocalleader="\\"
inoremap jk <Esc>
snoremap jk <Esc>
nnoremap Y y$
xnoremap $ $h

inoremap <M-n> <Esc>
vnoremap <M-n> <Esc>
if has('nvim')
  tnoremap <M-n> <C-\><C-n>
endif

augroup vimrc_crmap
  autocmd!
  autocmd BufRead * if &modifiable | nnoremap <buffer> <CR> za| endif
  autocmd BufRead * if &modifiable | xnoremap <buffer> <CR> za| endif
  autocmd BufRead * if &modifiable | nnoremap <buffer> <BS> <c-^>| endif
augroup END

if !exists('g:loaded_tmux_navigator')
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
endif
" TODO: get window layout, sensibly use left/right to move the split, rather
" than 'increase or decrease size'. Also have up/down not function on cmd window
nnoremap <C-Left> <C-w><
nnoremap <C-Right> <C-w>>

nnoremap 0 0^
xnoremap 0 0^
onoremap 0 ^
nnoremap ^ 0
xnoremap ^ 0

nnoremap Q q

nnoremap <expr> >> "\<Esc>" . repeat('>>', v:count1)
nnoremap <expr> << "\<Esc>" . repeat('<<', v:count1)

nnoremap <expr> j (v:count > 4 ? "m'" . v:count . 'j' : 'gj')
xnoremap <expr> j (v:count > 4 ? "m'" . v:count . 'j' : 'gj')
nnoremap <expr> k (v:count > 4 ? "m'" . v:count . 'k' : 'gk')
xnoremap <expr> k (v:count > 4 ? "m'" . v:count . 'k' : 'gk')
nnoremap gj j
xnoremap gj j
nnoremap gk k
xnoremap gk k

nnoremap n /<C-r>/<CR>
nnoremap N ?<C-r>/<CR>

if has('nvim')
  augroup vimrc_term
    autocmd!
    autocmd WinEnter term://* nohlsearch
    autocmd WinEnter term://* startinsert

    " Currently like this so I can unmap for specific plugins/terminal progs.
    autocmd TermOpen * tnoremap <buffer> <C-h> <C-\><C-n><C-w>h
    autocmd TermOpen * tnoremap <buffer> <C-j> <C-\><C-n><C-w>j
    autocmd TermOpen * tnoremap <buffer> <C-k> <C-\><C-n><C-w>k
    autocmd TermOpen * tnoremap <buffer> <C-l> <C-\><C-n><C-w>l
    autocmd TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>
  augroup END
endif

" Make cmd work as alt in MacVim
if has('mac')
  nnoremap <D-j> <M-j>
  nnoremap <D-k> <M-k>
  vnoremap <D-j> <M-j>
  vnoremap <D-k> <M-k>
endif


cnoreabbrev vh <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'vert help' : 'vh')<CR>
cnoreabbrev hh <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'help' : 'hh')<CR>
cnoreabbrev h <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'vert help' : 'h')<CR>
cnoreabbrev f <c-r>=(getcmdtype()==':' && getcmdpos()==1 ? 'find' : 'h')<CR>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>

nnoremap <C-q> <C-w>
xnoremap < <gv
xnoremap > >gv
cmap W!! w !sudo tee % >/dev/null
nnoremap cp yap<S-}>p
nnoremap cr /\<<C-r>"\><CR>cgn<C-r>.<ESC>
xnoremap / y/\<<C-r>"\><CR>zv

nnoremap g= gg=G``zz
nnoremap gQ gggqG``
nnoremap g<CR> i<CR><Esc>

inoremap <C-u> <Esc>v`[gU`]a
" }}}
" Leader: {{{
nnoremap <leader><CR> :nohlsearch<CR>
nnoremap <leader>cd :lcd %:p:h<CR>:pwd<CR>

nnoremap <leader>p "0p
nnoremap <leader>P "0P
xnoremap <leader>p "0p
xnoremap <leader>P "0P

" Overwritten in plugins.vim.
nnoremap <leader>ev :e $CFGDIR/settings.vim<CR>
nnoremap <leader>rv :so $MYVIMRC<CR>:execute 'set ft='.&ft<CR>:echo 'reloaded vimrc'<CR>zv

nnoremap <silent> <leader>tws :let @/='\v\s+$'<CR>:set hls<CR>

" Select last edited text. improved over `[v`], eg works with visual block
nnoremap <expr> <leader>v '`['.strpart(getregtype(), 0, 1).'`]'
nnoremap <leader>w :write<CR>
nnoremap <silent> <leader>col :syntax sync fromstart<CR>
" }}}
" Filetype: {{{
augroup vimrc_filetype_mappings
  autocmd!
  if exists(':helpclose')
    autocmd FileType help nnoremap <buffer> q :helpclose<CR>
  else
    autocmd FileType help nnoremap <buffer> q :q<CR>
  endif

  nnoremap <silent> <Plug>FirstSuggestionFixSpelling 1z= :call repeat#set("\<Plug>FirstSuggestionFixSpelling")<CR>
  autocmd FileType markdown nnoremap <buffer> <localleader>s <Plug>FirstSuggestionFixSpelling
augroup END  " vimrc_filetype_mappings"
" }}}
" LessSimple: {{{

nnoremap <silent><C-w>b :vert resize<CR>:resize<CR>:normal! ze<CR>

xnoremap s :s//g<Left><Left>
xnoremap gs y:%s/<C-r>"//g<Left><Left>

xnoremap <M-j> :move '>+1<CR>gv=gv
xnoremap <M-k> :move '<-2<CR>gv=gv
nnoremap <M-j> :move .+1<CR>==
nnoremap <M-k> :move .-2<CR>==
inoremap <M-j> <C-c>:move .+1<CR>==gi
inoremap <M-k> <C-c>:move .-2<CR>==gi

" }}}
" Autoload: {{{
" I want these to load even if --noplugins is used.
nnoremap <silent> <leader>do :call difference#orig()<cr>
nnoremap <silent> <leader>du :call difference#undobuf()<cr>
nnoremap <silent> <leader>ml :call modeline#append()<CR>

inoremap <silent> ( <C-r>=autopairs#check_and_insert('(')<CR>
inoremap <silent> ) <C-r>=autopairs#check_and_insert(')')<CR>
inoremap <silent> [ <C-r>=autopairs#check_and_insert('[')<CR>
inoremap <silent> ] <C-r>=autopairs#check_and_insert(']')<CR>
inoremap <silent> { <C-r>=autopairs#check_and_insert('{')<CR>
inoremap <silent> } <C-r>=autopairs#check_and_insert('}')<CR>
inoremap <silent> " <C-r>=autopairs#check_and_insert('"')<CR>
inoremap <silent> ' <C-r>=autopairs#check_and_insert("'")<CR>
inoremap <silent> <BS> <C-r>=autopairs#backspace()<CR>

onoremap <silent>ai :<C-u>call textobjects#indent(0)<CR>
onoremap <silent>ii :<C-u>call textobjects#indent(1)<CR>
xnoremap <silent>ai <Esc>:call textobjects#indent(0)<CR><Esc>gv
xnoremap <silent>ii <Esc>:call textobjects#indent(1)<CR><Esc>gv

xnoremap il ^og_
xnoremap al 0o$
onoremap il :<C-u>normal! ^vg_<CR>
onoremap al :<C-u>normal! 0v$<CR>
" }}}

" vim: set ts=2 sw=2 tw=99 et :
