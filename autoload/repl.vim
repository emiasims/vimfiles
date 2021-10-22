function! repl#send(...) range abort
  if a:0 == 0
    call s:send_line_or_fold()
  elseif exists('a:firstline')
    call s:send_lines(getline(a:firstline, a:lastline))
  elseif type(a:1) == 1  " string
    call s:send_lines([a:1])
  elseif type(a:1) == 3  " list
    call s:send_lines(a:1)
  endif
endfunction

function! s:send_line_or_fold() abort
  let fold_close = foldclosedend(line('.'))
  if fold_close == -1
    let fold_close = '.'
  endif
  call s:send_lines(getline('.', fold_close))
endfunction

function! s:send_lines(lines) abort
  if g:repl#termid == -1
    throw 'g:repl#termid is default value, term might not be open'
  endif
  let nl = exists('b:repl_join') ? b:repl_join : g:repl#join
  call chansend(g:repl#termid, ["\<C-u>" . join(a:lines, nl), ''])
  if &filetype ==# 'python' && len(a:lines) > 1
    call chansend(g:repl#termid, "\<CR>")
  endif
endfunction

function! repl#opfunc(type) abort
  let [lnum_start, col_start] = getpos("'[")[1:2]
  let [lnum_end, col_end] = getpos("']")[1:2]
  let lines = getline(lnum_start, lnum_end)
  call s:send_lines(lines)
endfunction

function! repl#winnr() abort " {{{1
  let winid = win_findbuf(g:repl#bufid)[0]
  return empty(winid) ? 0 : win_id2win(winid)
endfunction
