function! qf#delitem() range abort
  let qflist = getqflist()
  let cursor = getcurpos()[1:]
  call remove(qflist, a:firstline - 1, a:lastline - 1)
  call setqflist(qflist)
  call cursor(cursor)
endfunction
