function! rename#opfunc(type) abort
  if a:type == 'line'
    return
  endif
  normal! `[v`]d
  augroup rename_insert
    autocmd!
    autocmd InsertLeave * call s:refactor_var() | autocmd! rename_insert
  augroup END
  startinsert
endfunction

function! s:refactor_var() abort
  let l:prefix = get(s:rename_prefix, &filetype, '')
  execute 'normal! O' . l:prefix . "\<C-r>. = \<C-r>\"\<Esc>" 
endfunction

let s:rename_prefix = {'vim': 'let '}
