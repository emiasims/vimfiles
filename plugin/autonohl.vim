" https://github.com/neovim/neovim/issues/5581
" https://github.com/romainl/vim-cool/issues/9
noremap <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]

function! HlSearch()
  let s:pos = match(getline('.'), @/, col('.') - 1) + 1
  if s:pos != col('.')
    call StopHL()
  endif
endfunction

function! StopHL()
  if !v:hlsearch || mode() != 'n' || get(g:, 'anh#pause', 0)
    return
  else
    silent call feedkeys("\<Plug>(StopHL)", 'm')
  endif
endfunction

augroup SearchHighlight
  au!
  au CursorMoved * call HlSearch()
  au InsertEnter * call StopHL()
augroup END
