nnoremap <Space> :
xnoremap <Space> :
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
inoremap jk <C-]><Esc>
snoremap jk <Esc>
nnoremap Y y$

nnoremap <C-m> <Nop>
nnoremap <Cr> za

nnoremap zE zMzO
nnoremap zO zCzO
nnoremap zV zMzv
nnoremap ZQ <Cmd>qall!<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <expr> 0 getline('.')[: col('.') - 2] =~ '^\s*$' ? '0' : '0^'
xnoremap <expr> 0 getline('.')[: col('.') - 2] =~ '^\s*$' ? '0' : '0^'
onoremap <expr> 0 getline('.')[: col('.') - 2] =~ '^\s*$' ? '0' : '^'

nnoremap <expr> $ (v:count > 0 ? 'j$' : '$')
xnoremap <expr> $ (v:count > 0 ? 'j$h' : '$h')
onoremap <expr> $ (v:count > 0 ? 'j$' : '$')

inoremap <C-w> <C-g>u<C-w><C-g>u
inoremap <C-u> <C-g>u<C-u><C-g>u
inoremap <M-u> <C-k>*
cnoremap <M-u> <C-k>*
tnoremap <expr> <M-u> digraph_get('*' .. nr2char(getchar()))

nnoremap <silent> <expr> j (v:count > 4 ? "m'" . v:count . 'j' : 'gj')
xnoremap <silent> <expr> j (v:count > 4 ? "m'" . v:count . 'j' : 'gj')
nnoremap <silent> <expr> k (v:count > 4 ? "m'" . v:count . 'k' : 'gk')
xnoremap <silent> <expr> k (v:count > 4 ? "m'" . v:count . 'k' : 'gk')
nnoremap gj j
xnoremap gj j
nnoremap gk k
xnoremap gk k

nnoremap <silent> <expr> n 'Nn'[v:searchforward]
nnoremap <silent> <expr> N 'nN'[v:searchforward]

nnoremap <silent><C-w>b :vert resize \| resize<Cr>

nnoremap [a <Cmd>execute v:count1 . 'previous'<CR>
nnoremap ]a <Cmd>execute v:count1 . 'next'<CR>
nnoremap [b <Cmd>execute v:count1 . 'bprevious'<CR>
nnoremap ]b <Cmd>execute v:count1 . 'bnext'<CR>
nnoremap [l <Cmd>execute v:count1 . 'lprevious'<CR>
nnoremap ]l <Cmd>execute v:count1 . 'lnext'<CR>
nnoremap [q <Cmd>execute v:count1 . 'cprevious'<CR>
nnoremap ]q <Cmd>execute v:count1 . 'cnext'<CR>
nnoremap [L <Cmd>lfirst<CR>
nnoremap ]L <Cmd>llast<CR>
nnoremap [<Space> <Cmd>put!=repeat(nr2char(10), v:count1)\|silent! ']+1\|call repeat#set("[ ")<CR>
nnoremap ]<Space> <Cmd>put =repeat(nr2char(10), v:count1)\|silent! '[-1\|call repeat#set("] ")<CR>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-x> <C-a>

" inoreabbrev -> ➜

nnoremap c* <Cmd>let @/='\<'.expand('<cword>').'\>'<Cr>m`cgn
nnoremap c. <Cmd>let @/='\V'.escape(@", '\')<Cr>m`cgn<C-a><Esc>
nnoremap d. <Cmd>let @/='\V'.escape(@", '\')<Cr><Cr>m`dgn

nnoremap <expr> >> "\<Esc>" . repeat('>>', v:count1)
nnoremap <expr> << "\<Esc>" . repeat('<<', v:count1)
xnoremap < <gv
xnoremap > >gv

xnoremap <M-j> <Cmd>move '>+1<CR>gv=gv
xnoremap <M-k> <Cmd>move '<-2<CR>gv=gv
nnoremap <M-j> <Cmd>move .+1<CR>==
nnoremap <M-k> <Cmd>move .-2<CR>==
inoremap <M-j> <Cmd>move .+1<CR>==gi
inoremap <M-k> <Cmd>move .-2<CR>==gi

nnoremap <expr> ~ getline('.')[col('.') - 1] =~# '\a' ? '~' : 'w~'
nnoremap cp yap`]p
nnoremap g<Cr> i<Cr><Esc>l

" Select last edited text. improved over `[v`], eg works with visual block
nnoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'
onoremap <expr> gp '`['.strpart(getregtype(), 0, 1).'`]'

nnoremap <Plug>(SynStack) :<C-u>call SynStack()<CR>
function! SynStack()
  let group = synIDattr(synID(line('.'), col('.'), 1), 'name')
  let glist = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
  " let hlgroup = synIDattr(synIDtrans(hlID(group)), 'name')
  let hlgroup = '	Highlighting: ' . synIDattr(synID(line("."), col("."), 1), "name") . ' ➤ '
        \ . synIDattr(synID(line("."), col("."), 0), "name") . ' ➤ '
        \ . synIDattr(synIDtrans(synID(line("."), col("."), 1)), "name")
  echo group glist hlgroup
endfunc

onoremap <silent>ai <Cmd>call textobjects#indent(0)<CR>
onoremap <silent>ii <Cmd>call textobjects#indent(1)<CR>
xnoremap <silent>ai <Cmd>call textobjects#indent(0)<CR><Esc>gv
xnoremap <silent>ii <Cmd>call textobjects#indent(1)<CR><Esc>gv

if has('nvim')
  nnoremap <silent> <C-Up>    <Cmd>call winresize#go(1, v:count1)<CR>
  nnoremap <silent> <C-Down>  <Cmd>call winresize#go(1, -v:count1)<CR>
  nnoremap <silent> <C-Left>  <Cmd>call winresize#go(0, v:count1)<CR>
  nnoremap <silent> <C-Right> <Cmd>call winresize#go(0, -v:count1)<CR>
else
  nnoremap <silent> <Esc>[1;5A <Cmd>call winresize#go(1, v:count1)<CR>
  nnoremap <silent> <Esc>[1;5B <Cmd>call winresize#go(1, -v:count1)<CR>
  nnoremap <silent> <Esc>[1;5D <Cmd>call winresize#go(0, v:count1)<CR>
  nnoremap <silent> <Esc>[1;5C <Cmd>call winresize#go(0, -v:count1)<CR>
endif

onoremap ar a]
onoremap ir i]

nnoremap ]s m`]s
nnoremap [s m`[s
