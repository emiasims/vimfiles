function! textobjects#indent(inner) abort
  let l:i = indent(line('.'))
  if getline('.') !~? "^\\s*$"
    let l:p = line('.') - 1
    let l:nextblank = getline(l:p) =~? "^\\s*$"

    while l:p > 0 && ((! l:nextblank && indent(l:p) >= l:i) || (!a:inner && l:nextblank))
      -
      let l:p = line('.') - 1
      let l:nextblank = getline(l:p) =~? "^\\s*$"
    endwhile

    normal! 0V
    call cursor(line('.'), col('.'))
    let l:p = line('.') + 1
    let l:nextblank = getline(l:p) =~? "^\\s*$"
    while l:p <= line('$') && ((!l:nextblank && indent(l:p) >= l:i) || (!a:inner && l:nextblank))
      +
      let l:p = line('.') + 1
      let l:nextblank = getline(l:p) =~? "^\\s*$"
    endwhile
    normal! $
  endif
endfunction
