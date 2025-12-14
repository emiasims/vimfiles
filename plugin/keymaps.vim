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
xnoremap Y "+y

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
nnoremap [<Space> <Cmd>silent! put!=repeat(nr2char(10), v:count1)\|silent! ']+1\|call repeat#set("[ ")<CR>
nnoremap ]<Space> <Cmd>silent! put =repeat(nr2char(10), v:count1)\|silent! '[-1\|call repeat#set("] ")<CR>

cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-x> <C-a>

" inoreabbrev -> ➜

nnoremap c* <Cmd>let @/='\<'.expand('<cword>').'\>'<Cr>m`cgn
nnoremap c. <Cmd>let @/='\V'.escape(@", '\')<Cr>m`cgn<C-a><Esc>
nnoremap d. <Cmd>let @/='\V'.escape(@", '\')<Cr>m`dgn

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

onoremap <silent>ai <Cmd>call textobjects#indent(0)<CR>
onoremap <silent>ii <Cmd>call textobjects#indent(1)<CR>
xnoremap <silent>ai <Cmd>call textobjects#indent(0)<CR><Esc>gv
xnoremap <silent>ii <Cmd>call textobjects#indent(1)<CR><Esc>gv

function! s:winresize(vert, diff) abort
  let diff = winnr() == winnr(a:vert ? 'j' : 'l') ? a:diff : -a:diff
  execute (a:vert ? '' : 'vert ') .. 'resize ' .. (diff > 0 ? '+' : '') .. diff
endfunction

if has('nvim')
  nnoremap <silent> <C-Up>    <Cmd>call <SID>winresize(1, v:count1)<CR>
  nnoremap <silent> <C-Down>  <Cmd>call <SID>winresize(1, -v:count1)<CR>
  nnoremap <silent> <C-Left>  <Cmd>call <SID>winresize(0, v:count1)<CR>
  nnoremap <silent> <C-Right> <Cmd>call <SID>winresize(0, -v:count1)<CR>
else
  nnoremap <silent> <Esc>[1;5A <Cmd>call <SID>winresize(1, v:count1)<CR>
  nnoremap <silent> <Esc>[1;5B <Cmd>call <SID>winresize(1, -v:count1)<CR>
  nnoremap <silent> <Esc>[1;5D <Cmd>call <SID>winresize(0, v:count1)<CR>
  nnoremap <silent> <Esc>[1;5C <Cmd>call <SID>winresize(0, -v:count1)<CR>
endif

nnoremap <F3> <Cmd>messages clear<Bar>echohl Type<Bar>echo "Messages cleared."<Bar>echohl None<Cr>
nnoremap <F4> <Cmd>messages<Cr>
nnoremap <F5> <Cmd>update<Bar>mkview<Bar>edit<Bar>TSBufEnable highlight<Cr>
nnoremap <F6> <Cmd>UndotreeToggle<Cr>
nnoremap \gt <Cmd>exe "tabmove +" .. v:count1<Cr>
nnoremap \gT <Cmd>exe "tabmove -" .. v:count1<Cr>
nnoremap <F8> <Cmd>update<Bar>so%<Cr>

if has('nvim')
  " save mode but keep n vs t mode
  tnoremap <Plug>(termLeave) <C-\><C-n><Cmd>let b:last_mode = 'n'<Cr>
  tnoremap <Plug>(term2nmode) <C-\><C-n><Cmd>let b:last_mode = 't'<Cr>
  tnoremap <C-[> <C-[>
  tnoremap <C-Space> <Space>
  tnoremap <S-Space> <Space>
  tmap <C-h> <Plug>(term2nmode)<C-h>
  tmap <C-j> <Plug>(term2nmode)<C-j>
  tmap <C-k> <Plug>(term2nmode)<C-k>
  tmap <C-l> <Plug>(term2nmode)<C-l>
  tmap <C-^> <Plug>(term2nmode)<C-^>
  tmap <C-\> <Plug>(term2nmode)<C-w>p
  tmap <Esc> <Plug>(termLeave)
  tmap <M-n> <Plug>(termLeave)

  inoreabbrev nvim. vim.api.nvim_
  cnoreabbrev nvim. vim.api.nvim_
  inoreabbrev =nvim. =vim.api.nvim_
endif

onoremap ar a]
onoremap ir i]

nnoremap ]s m`]s
nnoremap [s m`[s

xnoremap gs :s//g<Left><Left>
cnoremap ! <C-]>!
inoremap <C-i> <C-i>
nnoremap <C-;> g;
nnoremap <C-,> g,
inoremap . .<C-]>
cnoremap . .<C-]>
cnoremap <C-t> <Home>tab split<Bar><End>
nnoremap <MiddleMouse> "*p
xnoremap <MiddleMouse> "*p
nnoremap <BS> "*
xnoremap <BS> "*
