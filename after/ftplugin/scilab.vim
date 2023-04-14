setlocal lisp
setlocal foldexpr=TstFold(v:lnum)
setlocal foldtext=fold#text()

function! TstFold(lnum) abort " {{{1
  if getline(a:lnum) =~ '^====\+$' && getline(a:lnum + 2) =~ '^====\+$'
    return '>1'
  endif
  return '='
endfunction
