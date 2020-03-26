function! yankring#reset() abort
  let s:yankring = []
  let s:maxyanks = max([get(g:, 'yankring#maxyanks', 10), 10])
  unlet! s:count
  for i in range(1, 9)
    call add(s:yankring, {'val': getreg(i), 'type': getregtype(i)})
  endfor
endfunction
call yankring#reset()

function! yankring#yank() abort
  echo 'yanked' v:event.regcontents v:event.regtype
  if !empty(v:event.regname) || len(join(v:event.regcontents)) <= get(g:, 'yankring#minlen', 3)
    return
  endif
  call insert(s:yankring, {'val': v:event.regcontents, 'type': v:event.regtype})
  if len(s:yankring) >= s:maxyanks
    call remove(s:yankring, s:maxyanks, -1)
  endif
  call yankring#sync()
endfunction

function! yankring#sync() abort
  for n in range(max([len(s:yankring), 9]))
    call setreg(n + 1, s:yankring[n].val, s:yankring[n].type)
  endfor
endfunction

" Not sure if all of these are necessary
function! yankring#cycle(count) abort
  let s:count = exists('s:count') ? (s:count + a:count) % s:maxyanks : 1
  if s:count < 0
    let s:count += s:maxyanks
  endif
  call setreg("", s:yankring[s:count].val, s:yankring[s:count].type)
  echo 'noautocmd normal! `[' . s:yankring[s:count].type[0] . '`]p'
  execute 'noautocmd normal! `[' . s:yankring[s:count].type[0] . '`]p'
endfunction

augroup yankring
  autocmd!
  autocmd TextYankPost * call yankring#yank()
  autocmd InsertEnter,BufWrite,BufLeave * unlet! s:count
augroup END

nnoremap <M-p> :<C-u>noautocmd call yankring#cycle(v:count1)<Cr>
nnoremap <M-n> :<C-u>noautocmd call yankring#cycle(-v:count1)<Cr>

command! -nargs=0 YankRingShow for i in range(len(s:yankring)) | echo i . ':' s:yankring[i].val | endfor
