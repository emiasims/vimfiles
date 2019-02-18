function! fold#text() abort
  let l:fs = v:foldstart
  while getline(l:fs) !~# '\w'
    let l:fs = nextnonblank(l:fs + 1)
  endwhile
  if l:fs > v:foldend
    let l:line = getline(v:foldstart)
  else
    let l:line = substitute(getline(l:fs), '\t', repeat(' ', &tabstop), 'g')
  endif

  let l:w = winwidth(0) - &foldcolumn - &number * &numberwidth
  let l:foldSize = 1 + v:foldend - v:foldstart
  let l:foldSizeStr = ' ' . l:foldSize . ' lines '
  let l:foldLevelStr = repeat('  +  ', v:foldlevel)
  let l:lineCount = line('$')
  let l:expansionString = repeat(' ', l:w - strwidth(l:foldSizeStr.l:line.l:foldLevelStr))
  return l:line . l:expansionString . l:foldSizeStr . l:foldLevelStr
endfunction

function! fold#markdown(lnum) abort
  let l:level = matchend(getline(a:lnum), '^#*')
  let l:nextlevel =  matchend(getline(a:lnum + 1), '^#*')
  if l:level > 0
    return '>' . l:level
  elseif l:nextlevel > 0
    return '<' . l:nextlevel
  endif
  return '='
endfunction

" vim: set ts=2 sw=2 tw=99 et :
