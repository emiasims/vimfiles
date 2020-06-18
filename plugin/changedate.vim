function! s:checkdate(lnum, regex) abort " {{{2
  let date = strftime('%Y %b %d', localtime())
  if getline(a:lnum) !~# date
    call setline(a:lnum, substitute(getline(a:lnum), a:regex, date, ''))
  endif
endfunction

augroup vimrc_date
  autocmd!
  autocmd BufWritePre *doc/*.txt call <SID>checkdate(1, '\clast change: \zs.*')
augroup END
