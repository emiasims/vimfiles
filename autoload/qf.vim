function! qf#delitem(...) range abort
  let b:deleted = get(b:, 'deleted', [])
  let qflist = getqflist()
  let cursor = getcurpos()[1:]
  call add(b:deleted, [a:firstline, a:lastline, remove(qflist, a:firstline - 1, a:lastline - 1)])
  call setqflist(qflist)
  call cursor(cursor)
  if a:0 == 0
    let b:redo = []
  endif
endfunction

function! qf#undo() abort
  let b:deleted = get(b:, 'deleted', [])
  if empty(b:deleted)
    echo 'Already at oldest change'
    return
  endif
  let [start, last, removals] = remove(b:deleted, -1)
  let qflist = getqflist()
  for item in reverse(removals)
    call insert(qflist, item, start - 1)
  endfor
  call setqflist(qflist)
  call add(b:redo, [start, last])
  execute start
endfunction

function! qf#redo() abort
  if !exists("b:redo") || empty(b:redo)
    echo 'Already at newest change'
    return
  endif
  let [start, end] = remove(b:redo, -1)
  execute printf('%d,%dcall qf#delitem(1)', start, end)
endfunction
