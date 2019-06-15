function! yankring#reset() abort
  let s:enabled = 1
  let s:count = 0
  let s:yankring = []
  for l:i in range(1, 9)
    execute 'let l:contents = @' . l:i
    call add(s:yankring, l:contents)
  endfor
endfunction
call yankring#reset()

function! yankring#yank(contents) abort
  let l:contents = join(a:contents, "\<C-j>")
  if len(l:contents) <= 1
    return
  endif
  call insert(s:yankring, l:contents)
  while len(s:yankring) > 9
    call remove(s:yankring, -1)
  endwhile
  call yankring#sync()
endfunction

function! yankring#sync() abort
  messages clear
  for l:n in range(len(s:yankring))
    execute 'let @' . l:n . ' = "' . escape(s:yankring[l:n], '"') . '"'
  endfor
endfunction

" TODO not working with counts
function! yankring#cycle(count) abort
  messages clear
  normal! `[v`]
  if a:count > 0
    let s:count = s:count == 9 ? 0 : s:count + a:count
  else
    let s:count = s:count == 0 ? 9 : s:count + a:count  " already is negative
  endif
  execute 'noautocmd normal! "' . s:count . 'p'
  echo 'put from "' . s:count
endfunction

augroup yankring
  autocmd!
  autocmd TextYankPost * if empty(v:event['regname']) | call yankring#yank(v:event['regcontents']) | endif
  autocmd InsertEnter,FocusLost,CursorHold,BufWrite * let s:count = 0
augroup END
