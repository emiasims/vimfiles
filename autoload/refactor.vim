function! refactor#expression_to_variable() abort
  let l:savereg = @"
  normal! gvy
  let s:expr = @"
  let s:lnum = line('.')
  call append(s:lnum - 1, '')
  let s:indent = matchstr(getline('.'), '^\s*')
  let s:start = getpos("'<")[2]
  let s:prefix = get(get(g:, 'refactor_prefix', {}), &filetype, '')
  let s:equals = get(get(g:, 'refactor_equals', {}), &filetype, ' = ')
  augroup refactor_insert
    autocmd!
    autocmd InsertLeave * autocmd! refactor_insert
    " Not this insert, but the NEXT will remove these autocmds, or insertleave. <C-c> avoidance
    autocmd InsertEnter * autocmd refactor_insert InsertEnter * autocmd! refactor_insert
    autocmd TextChangedI,TextChangedP * call s:update_refactor()
  augroup END
  let @" = l:savereg
endfunction

function! s:update_refactor() abort
  execute "let l:text = getline('.')[" . (s:start - 1) . ':' . (getcurpos()[2] - 2) . ']'
  call setline(s:lnum, s:indent . s:prefix . l:text . s:equals . s:expr)
endfunction

augroup refactor_clear
  autocmd!
  autocmd InsertLeave * autocmd! refactor_insert
augroup END

let g:refactor_prefix = {'vim': 'let '}
let g:refactor_equals = {'sh': '='}
