function! fold#text() abort " {{{1
  let fs = v:foldstart
  while getline(fs) !~# '\w'
    let fs = nextnonblank(fs + 1)
  endwhile
  if fs > v:foldend
    let line = getline(v:foldstart)
  else
    let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
  endif
  let line = matchstr(line, '.*\ze{{{\d*$')

  let w = winwidth(0) - &foldcolumn - &number * &numberwidth
  let foldSize = 1 + v:foldend - v:foldstart
  let foldSizeStr = ' ' . foldSize . ' lines '
  let foldLevelStr = repeat('  +  ', v:foldlevel)
  let expansionString = repeat(' ', w - strwidth(foldSizeStr.line.foldLevelStr))
  return line . expansionString . foldSizeStr . foldLevelStr
endfunction

function! fold#pythontext(...) abort " {{{1
  let foldstart = get(a:, 1, v:foldstart)
  let foldend = get(a:, 2, v:foldend)
  let foldlevel = get(a:, 3, v:foldlevel)
  let line = foldstart
  let decorators = []
  while getline(line) =~# '^\s*@'
    call add(decorators, matchstr(getline(line), '@\%(\w*\.\)*\zs\w*'))
    let line = nextnonblank(line + 1)
  endwhile
  let decoratortext = join(decorators) . ' '

  if decoratortext =~? '\v\@(numba.)?n?jit'
    let decoratortext = matchstr(decoratortext, 'n\?jit')
  endif

  let objtext = [getline(line)]
  let line = nextnonblank(line + 1)
  while objtext[-1] !~# ':$' && line <= foldend
    call add(objtext, matchstr(getline(line), '^\s*\zs.*$'))
    let line = nextnonblank(line + 1)
  endwhile
  let objtext = join(objtext, '')

  let maxlen = 64
  if len(objtext) > maxlen && objtext =~ '\w(.*)'
    let objtext = substitute(objtext, '(.*)', '( ... )', '')
  elseif len(objtext) > maxlen  " for docstrings
    let objtext = split(objtext, '\s\zs')
    let ot = ''
    while len(ot) < maxlen && !empty(objtext)
      let ot .= remove(objtext, 0)
    endwhile
    let objtext = ot . ' ...'
  endif

  let width = winwidth(0) - &foldcolumn - &number * &numberwidth - 2
  let linestr = (1 + foldend - foldstart) . ' lines '
  let rhs = max([len(linestr) + 1, 10])
  let foldstr = repeat('  +  ', foldlevel)
  let rhs_space = repeat(' ', rhs - strwidth(linestr))
  let mid_space = repeat(' ', width - rhs - strwidth(objtext . decoratortext . foldstr))
  return objtext . mid_space . decoratortext . rhs_space . linestr . foldstr
endfunction

function! fold#markdown(lnum) abort " {{{1
  let level = matchend(getline(a:lnum), '^#*')
  let nextlevel =  matchend(getline(a:lnum + 1), '^#*')
  if level > 0
    return '>' . level
  elseif nextlevel > 0
    return '<' . nextlevel
  endif
  return '='
endfunction

function! fold#python(lnum) abort " {{{1
  let text = getline(v:lnum)
  " account for: decorators, new classes/methods/functions
  if text !~# '\v^\s*(\@|def|class)@!\S'
    return '='
  elseif text =~# "^\s*$"
    let [nnb, pnb] = [nextnonblank(v:lnum), prevnonblank(v:lnum)]
    if v:lnum - nnb >= 3
    elseif text =~# "\v^\s*(def|class)>"
    elseif text =~? "^\s*@"
      " Only works with spaces
      return getline(v:lnum - 1) =~? "^\s*@" ? '=' : ('>' . indent(v:lnum) / &shiftwidth)
    endif
  endif
  if text =~# '\v^\s*(def|class)'
    return text =~# '^[dc]' ? ">1" : "a1"
  elseif text =~? '^\s\+\S'
    return "="
  endif

endfunction

function! fold#goto_open(direction) abort " {{{1
  let lnum = line('.')
  while foldclosed(lnum)
    let lnum = lnum + a:direction
  endwhile
  call cursor(start, 0)
endfunction
