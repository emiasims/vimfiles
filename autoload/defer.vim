function! s:onidle() abort
  autocmd! defer_idle

  execute 'doautocmd User DeferVim'
  execute 'autocmd! User DeferVim'
endfunction

augroup defer_idle
  if has('vim_starting')
    autocmd CursorHold,InsertEnter * call s:onidle()
  endif
augroup END

function! defer#onidle(evalable) abort
  execute 'autocmd User DeferVim ' . a:evalable
endfunction

call defer#onidle('set updatetime=' . &updatetime)
set updatetime=100  "  windows needs
