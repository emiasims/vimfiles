function! refactor#expression_to_variable(type, ...) abort
  let [l:lnum_start, l:col_start] = getpos(a:0 > 0 ? "'<" : "'[")[1:2]
  let [l:lnum_end, l:col_end] = getpos(a:0 > 0 ? "'>" : "']")[1:2]
  let s:lnum = line('.')
  let s:expr = getline(s:lnum)[l:col_start - 1 : l:col_end - 1]
  messages clear
  echom '"'.s:expr.'"'
  call append(s:lnum - 1, '')
  let s:indent = matchstr(getline('.'), '^\s*')
  let s:start = getpos("'<")[2]
  let s:prefix = get(get(g:, 'refactor_prefix', {}), &filetype, '')
  let s:equals = get(get(g:, 'refactor_equals', {}), &filetype, ' = ')
  augroup vimrc_refactor_insert
    autocmd!
    autocmd InsertLeave * autocmd! vimrc_refactor_insert
    " Not this insert, but the NEXT will remove these autocmds, or insertleave. <C-c> avoidance
    autocmd InsertEnter * autocmd vimrc_refactor_insert InsertEnter * autocmd! vimrc_refactor_insert
    autocmd TextChangedI,TextChangedP * call s:update_refactor()
  augroup END
  execute 'normal! ' . (a:0 > 0 ? "`<" : "`[") . 'v' . (a:0 > 0 ? "`>" : "`]"). 'd'
  startinsert
endfunction

" TODO rename like above in file, but not cross project.
" TODO after that, in all visible windows.
function! refactor#function_in_project(type, ...) abort
  let [l:lnum_start, l:col_start] = getpos(a:0 > 0 ? "'<" : "'[")[1:2]
  let [l:lnum_end, l:col_end] = getpos(a:0 > 0 ? "'>" : "']")[1:2]
  let l:expr = getline(line('.'))[l:col_start - 1 : l:col_end - 1]
  execute 'vimgrep /' . l:expr . '/j **/*.' . &filetype
  call feedkeys(":cdo s/" . l:expr . "//g\<Left>\<Left>")
endfunction

function! s:update_refactor() abort
  let l:text = getline('.')[ (s:start - 1) : (getcurpos()[2] - 2) ]
  call setline(s:lnum, s:indent . s:prefix . l:text . s:equals . s:expr)
endfunction

augroup refactor_clear
  autocmd!
  autocmd InsertLeave * silent! autocmd! vimrc_refactor_insert
augroup END

let g:refactor_prefix = {'vim': 'let '}
let g:refactor_equals = {'sh': '='}
