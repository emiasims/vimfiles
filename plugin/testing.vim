function! testing#goto() abort " {{{1
  let flnum = search('\v^function! (s:)@!', 'cnbW')
  if !flnum
    echoerr 'No function found'
    return
  endif
  let fname = matchstr(getline(flnum), '^function! \zs.*\ze(')
  let parts = split(fname, '#')
  let parts[0] = parts[0] =~# 'test$' ? parts[0][:-5] : parts[0] . 'test'
  execute 'tag' join(parts, '#')
endfunction

nnoremap <Plug>(testing-goto) :call testing#goto()<Cr>
