let s:yankring = []
let s:maxyanks = max([get(g:, 'yankring#maxyanks', 10), 10])
unlet! s:count
for i in range(1, 9)
  call add(s:yankring, {'val': getreg(i), 'type': getregtype(i)})
endfor

function! yankring#yank() abort
  if !empty(v:event.regname) || len(join(v:event.regcontents)) <= get(g:, 'yankring#minlen', 3)
    return
  endif
  call insert(s:yankring, {'val': v:event.regcontents, 'type': v:event.regtype})
  if len(s:yankring) > s:maxyanks
    call remove(s:yankring, s:maxyanks, -1)
  endif
endfunction

function! yankring#clearcheck() abort " {{{1
  if !exists('s:count')
    return
  endif
  let [start, end, curs] = [getpos("'[")[1:2], getpos("']")[1:2], getcurpos()[1:2]]
  if !(curs[0] >= start[0] && curs[1] >= start[1] && curs[0] <= end[1] && curs[1] <= end[1])
    unlet s:count
  endif
endfunction

function! yankring#setup() abort " {{{1
  let s:count = 0
endfunction

function! yankring#cycle(count) abort
  if !exists('s:count')
    echo "No put context to cycle"
    return
  endif
  echo s:count
  let s:count = (s:count + a:count) % s:maxyanks
  if s:count < 0
    let s:count += s:maxyanks
  endif
  call setreg("", s:yankring[s:count].val, s:yankring[s:count].type)
  normal! up
endfunction

augroup yankring
  autocmd!
  autocmd TextYankPost * call yankring#yank()
  autocmd CursorMoved * call yankring#clearcheck()
augroup END

nnoremap <silent> <M-p> :<C-u>noautocmd call yankring#cycle(v:count1)<Cr>
nnoremap <silent> <M-n> :<C-u>noautocmd call yankring#cycle(-v:count1)<Cr>
nnoremap <silent> p p:call yankring#setup()<Cr>

command! -nargs=0 YankRingShow for i in range(len(s:yankring)) | echo i . ':' s:yankring[i].val | endfor
