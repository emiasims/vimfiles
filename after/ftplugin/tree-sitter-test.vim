setlocal lisp
setlocal foldexpr=TstFold(v:lnum)
setlocal foldmethod=expr

function! TstFold(lnum) abort " {{{1
  if getline(a:lnum) =~ '^====\+$' && getline(a:lnum + 2) =~ '^====\+$'
    return '>1'
  endif
  return '='
endfunction
