nnoremap <Space> :
xnoremap <Space> :
cnoremap <expr> <space> (getcmdtype()==":" && empty(getcmdline())) ? 'lua ' : '<C-]> '
nnoremap ! :!

if !has('nvim')
  " C-space in kitty with my settings
  nnoremap [32;5u <Space>
  inoremap [32;5u <Space>
endif

inoremap <C-c> <Esc>
inoremap <Esc> <C-c>
snoremap <C-c> <Esc>
snoremap <Esc> <C-c>
inoremap jk <Esc>
snoremap jk <Esc>
nnoremap Y y$

augroup vimrc_crmap
  autocmd!
  " Not sure why quickfix lists are modifiable.
  autocmd BufEnter * if &modifiable | nnoremap <buffer> <Cr> za| endif
augroup END

nnoremap zE zMzO
nnoremap zO zCzO
nnoremap zV zMzv

if !exists('g:loaded_tmux_navigator')
  nnoremap <C-h> <C-w>h
  nnoremap <C-j> <C-w>j
  nnoremap <C-k> <C-w>k
  nnoremap <C-l> <C-w>l
endif

nnoremap <expr> 0 getline('.')[: col('.') - 2] =~ '^\s*$' ? '0' : '0^'
xnoremap <expr> 0 getline('.')[: col('.') - 2] =~ '^\s*$' ? '0' : '0^'
onoremap <expr> 0 getline('.')[: col('.') - 2] =~ '^\s*$' ? '0' : '^'

nnoremap <expr> $ (v:count > 0 ? 'j$' : '$')
xnoremap <expr> $ (v:count > 0 ? 'j$h' : '$h')
onoremap <expr> $ (v:count > 0 ? 'j$' : '$')

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

nnoremap <silent><C-w>z :vert resize | resize | normal! ze<CR>

nnoremap [a :<C-u>execute v:count1 . 'previous'<CR>
nnoremap ]a :<C-u>execute v:count1 . 'next'<CR>
nnoremap [b :<C-u>execute v:count1 . 'bprevious'<CR>
nnoremap ]b :<C-u>execute v:count1 . 'bnext'<CR>
nnoremap [l :<C-u>execute v:count1 . 'lprevious'<CR>
nnoremap ]l :<C-u>execute v:count1 . 'lnext'<CR>
nnoremap [q :<C-u>execute v:count1 . 'cprevious'<CR>
nnoremap ]q :<C-u>execute v:count1 . 'cnext'<CR>
nnoremap [L :lfirst<CR>
nnoremap ]L :llast<CR>
nnoremap [<Space> :<C-u>silent! put!=repeat(nr2char(10), v:count1)\|']+1\|call repeat#set("[ ")<CR>
nnoremap ]<Space> :<C-u>silent! put =repeat(nr2char(10), v:count1)\|'[-1\|call repeat#set("] ")<CR>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-x> <C-a>

inoreabbrev -> ➜

nnoremap c* :<C-u>let @/ = '\<'.expand('<cword>').'\>'<Cr>cgn
nnoremap c. /\V<C-r>=escape(@", '\')<Cr><Cr>cgn<C-a><Esc>
nnoremap d. /\V<C-r>=escape(@", '\')<Cr><Cr>dgn

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

nnoremap <expr> ~ getline('.')[col('.') - 1] =~# '\a' ? '~' : 'w~'
nnoremap cp yap}p
nnoremap g<Cr> i<Cr><Esc>l

nnoremap <expr> <silent> g<Space> :<C-u>autocmd TextChangedI <buffer> ++once stopinsert<Cr>i

" nnoremap <silent> <C-]> g<C-]>
" " TODO: Generalized split function that simply splits vertical or horizontal depending on how those
" " are already split. Vert first, then horizontal.
" nnoremap <silent> g] :vert stjump<CR>
" nnoremap <silent> g<C-]> :stjump<CR>

nnoremap \p "0p
nnoremap \P "0P
xnoremap \p "0p
xnoremap \P "0P

xnoremap \y "*y
xnoremap \Y "+y

" Select last edited text. improved over `[v`], eg works with visual block
nnoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'
onoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'

nnoremap <F9> :<C-u>call SynStack()<CR>
function! SynStack()
  let group = synIDattr(synID(line('.'), col('.'), 1), 'name')
  let glist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  " let hlgroup = synIDattr(synIDtrans(hlID(group)), 'name')
  let hlgroup = '	Highlighting: ' . synIDattr(synID(line("."), col("."), 1), "name") . ' ➤ '
        \ . synIDattr(synID(line("."), col("."), 0), "name") . ' ➤ '
        \ . synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name")
  echo group glist hlgroup
endfunc

onoremap <silent>ai :<C-u>call textobjects#indent(0)<CR>
onoremap <silent>ii :<C-u>call textobjects#indent(1)<CR>
xnoremap <silent>ai <Esc>:call textobjects#indent(0)<CR><Esc>gv
xnoremap <silent>ii <Esc>:call textobjects#indent(1)<CR><Esc>gv

if has('nvim')
  nnoremap <silent> <C-Up>    :<C-u>call winresize#go(1, v:count1)<CR>
  nnoremap <silent> <C-Down>  :<C-u>call winresize#go(1, -v:count1)<CR>
  nnoremap <silent> <C-Left>  :<C-u>call winresize#go(0, v:count1)<CR>
  nnoremap <silent> <C-Right> :<C-u>call winresize#go(0, -v:count1)<CR>
else
  nnoremap <silent> <Esc>[1;5A :<C-u>call winresize#go(1, v:count1)<CR>
  nnoremap <silent> <Esc>[1;5B :<C-u>call winresize#go(1, -v:count1)<CR>
  nnoremap <silent> <Esc>[1;5D :<C-u>call winresize#go(0, v:count1)<CR>
  nnoremap <silent> <Esc>[1;5C :<C-u>call winresize#go(0, -v:count1)<CR>
endif

nnoremap <silent> <F2> :call util#openf(expand("<cfile>"))<CR>
xnoremap <silent> <F2> :<C-u>call util#openf(util#get_visual_selection())<CR>

onoremap ar a]
onoremap ir i]

nnoremap ]s m`]s
nnoremap [s m`[s
