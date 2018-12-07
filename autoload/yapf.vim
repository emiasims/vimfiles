function! yapf#yapfify(start, end) abort
  let l:cursor = getpos('.')
  silent execute '0,$! ' . 'yapf --lines=' . a:start . '-' . a:end
  if v:shell_error  " restore buffer and put error into a new buffer
    let l:error = getline(1, '$')
    silent undo
    echom l:error
    echohl WarningMsg
    echom 'Check syntax and :messages. yapf returned an error.'
    echohl None
  endif
  call setpos('.', l:cursor)
endfunction

" vim: set ts=2 sw=2 tw=99 et :
