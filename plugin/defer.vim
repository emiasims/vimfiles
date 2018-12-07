" TODO: List of 'files' to call in order
let s:filename = 'DeferVim'

function! s:onidle() abort
  autocmd! defer_idle

  execute 'doautocmd User ' . s:filename
  execute 'autocmd! User ' . s:filename
endfunction

augroup defer_idle
  if has('vim_starting')
    autocmd CursorHold,InsertEnter * call s:onidle()
  endif
augroup END

function! defer#onidle(evalable) abort
  execute 'autocmd User ' . s:filename . ' ' . a:evalable
endfunction

call defer#onidle('set updatetime=' . &updatetime)
set updatetime=100  "  windows needs
