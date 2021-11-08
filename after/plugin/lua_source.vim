augroup vimrc_srclua
  autocmd!
  autocmd SourceCmd *.lua call v:lua.mia.source.fn(expand('<amatch>'))
augroup END

