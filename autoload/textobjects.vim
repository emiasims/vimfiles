function! textobjects#indent(inner) abort
  let i = indent(line('.'))
  if getline('.') !~? "^\\s*$"
    let p = line('.') - 1
    let nextblank = getline(p) =~? "^\\s*$"

    while p > 0 && ((! nextblank && indent(p) >= i) || (!a:inner && nextblank))
      -
      let p = line('.') - 1
      let nextblank = getline(p) =~? "^\\s*$"
    endwhile

    normal! 0V
    call cursor(line('.'), col('.'))
    let p = line('.') + 1
    let nextblank = getline(p) =~? "^\\s*$"
    while p <= line('$') && ((!nextblank && indent(p) >= i) || (!a:inner && nextblank))
      +
      let p = line('.') + 1
      let nextblank = getline(p) =~? "^\\s*$"
    endwhile
    normal! $
  endif
endfunction
