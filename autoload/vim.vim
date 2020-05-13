function! vim#if2tern() abort " {{{1
  let istart = search('^\s*if', 'nbW', line('w0'))
  let iend = search('^\s*endif', 'nW', line('w$'))
  if (istart == 0 || iend == 0) || !(istart + 2 == iend || istart + 4 == iend)
    echoerr 'Not within simple if statement'
    return
  endif
  messages clear
  echom getline(istart)
  let cond = matchstr(getline(istart), '^\s*if\s*\zs.*$')
  let [assignment, iftrue] = matchlist(getline(istart + 1), '\v^\s*(let[^=]*\= )(.*)$')[1:2]
  let iffalse = iend - istart == 4 ? matchstr(getline(iend - 1), '\v^\s*let[^=]*\= \zs.*$') : ''
  execute istart . ',' . (iend - 1) . 'd'
  call setline(istart, assignment . cond . ' ? ' . iftrue . ' : ' . iffalse)
  call cursor(istart, 1)
  normal! w==
  if iend - istart == 2
    startinsert!
  endif
endfunction

function! vim#tern2if() abort " {{{1
  let [asgn, cond, iftrue, iffalse] = matchlist(getline('.'), '\v\s*(let[^=]*\= )(.*) \? (.*) : (.*)')[1:4]
  call setline('.', 'if ' . cond)
  call append('.', [asgn . iftrue, 'else', asgn . iffalse, 'endif'])
  normal! =4j
endfunction

function! vim#sortfunctions() abort range " {{{1
  let start = nextnonblank(a:firstline == a:lastline ? 1 : a:firstline)
  let end = prevnonblank(a:firstline == a:lastline ? line('$') : a:lastline)
  let atend = getpos("'>")[1] == line('$')
  execute 'silent! ' . start . ',' . end . 's/\n/@@@@@@/'
  silent! s/@@@@@@\zefunction/\r/g
  silent! '[,']sort
  let startln = getpos("'[")[1]
  if atend
    silent ']s/@@@@@@$//g
  endif
  execute 'silent!' startln . ",']s/@@@@@@/\r/g"
endfunction
