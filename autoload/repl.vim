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
  let l:fold_close = foldclosedend(line('.'))
  if l:fold_close == -1
    let l:fold_close = '.'
  endif
  call s:send_lines(getline('.', l:fold_close))
endfunction

function! s:send_lines(lines) abort
  if g:repl#termid == -1
    throw 'g:repl#termid is default value, term might not be open'
  endif
  call chansend(g:repl#termid, ["\<C-u>" . join(a:lines, "\<CR>\<C-u>"), ''])
  if &filetype ==# 'python' && len(a:lines) > 1
    call chansend(g:repl#termid, "\<CR>")
  endif
endfunction

function! repl#opfunc(type) abort
  let [l:lnum_start, l:col_start] = getpos("'[")[1:2]
  let [l:lnum_end, l:col_end] = getpos("']")[1:2]
  let l:lines = getline(l:lnum_start, l:lnum_end)
  call s:send_lines(l:lines)
endfunction

function! repl#winnr() abort " {{{1
  let winid = win_findbuf(g:repl#bufid)[0]
  return empty(winid) ? 0 : win_id2win(winid)
endfunction
