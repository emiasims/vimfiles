" Settings:
" General: {{{
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
set timeoutlen=750  " Time out on mappings
set ttimeoutlen=250 " for key codes
" }}}
" Backup, Swap, Undo, History: {{{
if exists('$SUDO_USER')
  set nowritebackup
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
set noswapfile
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

" Save when exiting a buffer/window. Saving on idle is a bit too aggressive for me.
set autowriteall
augroup vimrc_writeall
  autocmd!
  autocmd WinLeave * ++nested if &modifiable && &modified && filereadable(expand('%')) | write | endif
augroup END

if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor
  " let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " let g:ctrlp_use_caching = 0
endif

set splitright
set switchbuf=useopen,usetab
set backspace=indent,eol,start
set diffopt=algorithm:histogram,filler
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
if has('nvim') && !empty($CONDA_PYTHON_EXE)
  let g:python3_host_prog = $CONDA_PYTHON_EXE
endif
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
        \ if &filetype ==# '' || exists('b:ftdetect')
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
  autocmd InsertLeave * if &diff | diffupdate | endif

  " TODO: save values
  autocmd WinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline

augroup END

augroup vimrc_numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

" augroup vimrc_savemarks
"   autocmd!
"   autocmd TextChanged,InsertLeave,TextYankPost * let b:savemarks = [getpos("'["), getpos("']")]
"   autocmd BufWritePost * if exists('b:savemarks') | call setpos("'[", b:savemarks[0]) | call setpos("']", b:savemarks[1]) | endif
" augroup end

" }}}
" Filetype: {{{
augroup vimrc_filetype
  autocmd!
  autocmd FileType qfreplace setlocal nofoldenable
  autocmd FileType sh let g:is_bash=1
  autocmd FileType sh let g:sh_fold_enabled=5
  autocmd BufRead * if empty(&filetype) | set commentstring=#%s | endif
augroup END    " vimrc_filetype
" }}}

" Mappings:
let g:mapleader=' '
let g:maplocalleader="\\"
" File navigation {{{
if !exists('g:loaded_fzf')
  nnoremap <leader>ev :e $CFGDIR<CR>
endif
" }}}
" Cursor Navigation and Windows: {{{
nnoremap <Space> <nop>
xnoremap <Space> <nop>

inoremap <C-c> <Esc>
inoremap <Esc> <C-c>
snoremap <C-c> <Esc>
snoremap <Esc> <C-c>
inoremap jk <Esc>
snoremap jk <Esc>
nnoremap Y y$

augroup vimrc_crmap
  autocmd!
  autocmd BufRead * if &modifiable | nnoremap <buffer> <CR> za| endif
augroup END

nnoremap zE zMzO
nnoremap zO zCzO
nnoremap zV zMzv

nnoremap <C-]> g<C-]>

if !exists('g:loaded_tmux_navigator')
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
endif

nnoremap <expr> 0 search('^\s\+\%#', 'bn', line('.')) ? '0' : '0^'
xnoremap <expr> 0 search('^\s\+\%#', 'bn', line('.')) ? '0' : '0^'
onoremap <expr> 0 search('^\s\+\%#', 'bn', line('.')) ? '0' : '0^'

nnoremap <expr> $ (v:count > 0 ? 'j$' : '$')
xnoremap <expr> $ (v:count > 0 ? 'j$h' : '$h')
onoremap <expr> $ (v:count > 0 ? 'j$' : '$')

nnoremap Q q

inoremap <C-f> <C-g>U<Right>
inoremap <C-b> <C-g>U<Left>

inoremap <C-w> <C-g>u<C-w><C-g>u
inoremap <C-u> <C-g>u<C-u><C-g>u
inoremap <M-u> <C-k>*

nnoremap <expr> j (v:count > 4 ? "m'" . v:count . 'j' : 'gj')
xnoremap <expr> j (v:count > 4 ? "m'" . v:count . 'j' : 'gj')
nnoremap <expr> k (v:count > 4 ? "m'" . v:count . 'k' : 'gk')
xnoremap <expr> k (v:count > 4 ? "m'" . v:count . 'k' : 'gk')
nnoremap gj j
xnoremap gj j
nnoremap gk k
xnoremap gk k

nnoremap <expr> n 'Nn'[v:searchforward]
nnoremap <expr> N 'nN'[v:searchforward]

nnoremap <silent><C-w>b :vert resize<CR>:resize<CR>:normal! ze<CR>

nnoremap <silent> [a :<C-u>execute v:count1 . 'previous'<CR>
nnoremap <silent> ]a :<C-u>execute v:count1 . 'next'<CR>
nnoremap <silent> [b :<C-u>execute v:count1 . 'bprevious'<CR>
nnoremap <silent> ]b :<C-u>execute v:count1 . 'bnext'<CR>
nnoremap <silent> [l :<C-u>execute v:count1 . 'lprevious'<CR>
nnoremap <silent> ]l :<C-u>execute v:count1 . 'lnext'<CR>
nnoremap <silent> [q :<C-u>execute v:count1 . 'cprevious'<CR>
nnoremap <silent> ]q :<C-u>execute v:count1 . 'cnext'<CR>
nnoremap <silent> [L :lfirst<CR>
nnoremap <silent> ]L :llast<CR>
nnoremap <silent> [<Space> :<C-u>put!=repeat(nr2char(10), v:count1) \| ']+1 <CR>
nnoremap <silent> ]<Space> :<C-u>put =repeat(nr2char(10), v:count1) \| '[-1 <CR>
" }}}
" Terminal bindings: {{{
if has('nvim')
  augroup vimrc_term
    autocmd!
    autocmd WinEnter term://* nohlsearch
    autocmd WinEnter term://* if !exists('b:last_mode') | let b:last_mode = 't' | endif
    autocmd WinEnter term://* if b:last_mode == 't' | startinsert | endif
    autocmd TermLeave term://* let b:last_mode = 'n'
  augroup END

  tnoremap <Plug>(term2nmode) <C-\><C-n>:silent let b:last_mode = 't'<Cr>
  tmap <C-h> <Plug>(term2nmode)<C-w>h
  tmap <C-j> <Plug>(term2nmode)<C-w>j
  tmap <C-k> <Plug>(term2nmode)<C-w>k
  tmap <C-l> <Plug>(term2nmode)<C-w>l
  tmap <C-\> <Plug>(term2nmode)<C-w>p
  tnoremap <Esc> <C-\><C-n>
  tnoremap <M-n> <C-\><C-n>

endif
" }}}
" Command: {{{
" Just makes sure the abbrev only works at the start of the command
function! s:cnoreabbrev_at_command_start(...) abort
  let [options, rhs] = [[], []]
  let expr = a:000[0] =~? '^<expr>$'
  let expr = index(a:000, '<expr>', 0, 1) >= 0
  let buffer = index(a:000, '<buffer>', 0, 1) >= 0
  let mods = expr + buffer
  let lhs =  a:000[mods]
  let rhs = substitute(join(a:000[mods + 1:]), "'", '"', 'g')
  let truefalse = (expr ? rhs : '"' . rhs . '"') . ' : "' . lhs . '"'
  execute 'cnoreabbrev ' . (buffer ? '<buffer> ' : '') . lhs . ' <C-r>=(getcmdtype()==":" && getcmdpos()==1 ? ' . truefalse . ')<Cr>'
endfunction

command! -nargs=+ Cnoreabbrevs call <SID>cnoreabbrev_at_command_start(<f-args>)

Cnoreabbrevs e! mkview \| edit!
Cnoreabbrevs he help
Cnoreabbrevs h vert help
Cnoreabbrevs use UltiSnipsEdit
Cnoreabbrevs <expr> eft 'edit $CFGDIR/after/ftplugin/' . &filetype . '.vim'
Cnoreabbrevs ase AutoSourceEnable
Cnoreabbrevs asd AutoSourceDisable
Cnoreabbrevs sr SetRepl
Cnoreabbrevs tr TermRepl

cnoremap <expr> vga getcmdtype()==":" && getcmdpos()==1 ? 'vimgrep // **/*.' . &ft . "\<C-Left><Left><Left>" : 'vga'
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-x> <C-a>
" }}}
" Searching: {{{
nnoremap cr /\<<C-r>"\><CR>cgn<C-r>.<ESC>
xnoremap s :s//g<Left><Left>
xnoremap <C-s> :s/<C-r>///g<left><left>
xnoremap gs y:%s/<C-r>"//g<Left><Left>
" }}}
" Moving text: {{{
nnoremap <expr> >> "\<Esc>" . repeat('>>', v:count1)
nnoremap <expr> << "\<Esc>" . repeat('<<', v:count1)
xnoremap < <gv
xnoremap > >gv

xnoremap <M-j> :move '>+1<CR>gv=gv
xnoremap <M-k> :move '<-2<CR>gv=gv
nnoremap <M-j> :move .+1<CR>==
nnoremap <M-k> :move .-2<CR>==
inoremap <M-j> <C-c>:move .+1<CR>==gi
inoremap <M-k> <C-c>:move .-2<CR>==gi
" }}}
" Editing text: {{{
nnoremap <expr> ~ getline('.')[col('.') - 1] =~# '\a' ? '~' : 'w~'
nnoremap cp yap}p
nnoremap g<CR> i<CR><Esc>

nnoremap <silent> g<Space> :autocmd TextChangedI <buffer> ++once stopinsert<Cr>i
" TODO make repeatable?
nnoremap <silent> g2<Space> :autocmd InsertCharPre <buffer> ++once call feedkeys('lli' . v:char . '<C-v><Esc>', 'n') \| stopinsert<Cr>i
" vim-surround:
xmap g2<Space> S

" nnoremap <silent> <C-]> g<C-]>
" " TODO: Generalized split function that simply splits vertical or horizontal depending on how those
" " are already split. Vert first, then horizontal.
" nnoremap <silent> g] :vert stjump<CR>
" nnoremap <silent> g<C-]> :stjump<CR>

nnoremap <leader>p "0p
nnoremap <leader>P "0P
xnoremap <leader>p "0p
xnoremap <leader>P "0P

" Select last edited text. improved over `[v`], eg works with visual block
nnoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'
" }}}
" Plugins (manual): {{{
" I want these to load even if --noplugins is used.
" nnoremap <silent> <leader>do :call difference#orig()<cr>
nnoremap <silent> <leader>do :call difference#orig()<cr>
nnoremap <silent> <leader>du :call difference#undobuf()<cr>

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

nnoremap <silent> <C-Up>    :<C-u>call winresize#up(v:count1)<CR>
nnoremap <silent> <C-Down>  :<C-u>call winresize#down(v:count1)<CR>
nnoremap <silent> <C-Left>  :<C-u>call winresize#left(v:count1)<CR>
nnoremap <silent> <C-Right> :<C-u>call winresize#right(v:count1)<CR>

nnoremap ]p <silent> :<C-u>call yankring#cycle(v:count1)<CR>
nnoremap [p <silent> :<C-u>call yankring#cycle(-v:count1)<CR>

nnoremap <silent> <leader>R :<C-u>set opfunc=refactor#expression_to_variable<CR>g@
xnoremap <silent> R         :<C-u>call refactor#expression_to_variable(visualmode(), 1)<CR>
nnoremap <silent> gR        :<C-u>set opfunc=refactor#name_in_project<CR>g@
xnoremap <silent> gR        :<C-u>call refactor#name_in_project(visualmode(), 1)<CR>

nnoremap <silent> <F2> :call util#openf(expand("<cfile>"))<CR>
xnoremap <silent> <F2> :call util#openf(util#get_visual_selection())<CR>

nnoremap ]z zj:call fold#goto_open(1)<Cr>
nnoremap [z zk:call fold#goto_open(-1)<Cr>

" Not plugins but fits in with the text objects above
xnoremap il ^og_
xnoremap al 0o$
onoremap il :<C-u>normal! ^vg_<CR>
onoremap al :<C-u>normal! 0v$<CR>
" }}}
" Commands: {{{
command! Clearqflist call setqflist([])
command! -nargs=? -complete=buffer Clearloclist call setloclist(empty(<q-args>) ? 0 : bufnr(<q-args>), [])

" }}}
