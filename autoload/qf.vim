function! qf#delitem() abort
  let cursor = getcurpos()[1:]
  let qflist = getqflist()
  call remove(qflist, line('.') - 1)
  call setqflist(qflist)
  call cursor(cursor)
endfunction
