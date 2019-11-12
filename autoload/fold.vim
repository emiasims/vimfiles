function! fold#text() abort " {{{1
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

function! fold#pythontext(...) abort " {{{1
  " A bit sloppy but works for now
  let l:foldstart = get(a:, 1, v:foldstart)
  let l:foldend = get(a:, 1, v:foldend)
  let l:fs = l:foldstart
  while getline(l:fs) !~# '\w'
    let l:fs = nextnonblank(l:fs + 1)
  endwhile
  if l:fs > l:foldend
    let l:fs = l:foldstart
  endif

  let decorator = ''
  if getline(l:fs) =~# '^\s*@'
    let decorator = matchstr(getline(l:fs), '@\%(\w*\.\)*\zs\w*') . ' '
    let l:fs = nextnonblank(l:fs + 1)
  endif

  if decorator =~? '\v\@(numba.)?n?jit'
    let decorator = matchstr(decorator, 'n\?jit')
  endif

  let l:line = substitute(getline(l:fs), '\t', repeat(' ', &tabstop), 'g')

  let l:w = winwidth(0) - &foldcolumn - &number * &numberwidth
  let l:foldSize = 1 + l:foldend - l:foldstart
  let l:foldSizeStr = decorator . ' ' . l:foldSize . ' lines '
  let l:foldLevelStr = repeat('  +  ', v:foldlevel)
  let l:lineCount = line('$')
  let l:expansionString = repeat(' ', l:w - strwidth(l:foldSizeStr.l:line.l:foldLevelStr))
  return l:line . l:expansionString . l:foldSizeStr . l:foldLevelStr
endfunction

function! fold#markdown(lnum) abort " {{{1
  let l:level = matchend(getline(a:lnum), '^#*')
  let l:nextlevel =  matchend(getline(a:lnum + 1), '^#*')
  if l:level > 0
    return '>' . l:level
  elseif l:nextlevel > 0
    return '<' . l:nextlevel
  endif
  return '='
endfunction
