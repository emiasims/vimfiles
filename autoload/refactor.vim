function! refactor#expression_to_variable(type, ...) abort " {{{1
  let [line_start, col_start] = getpos(a:0 > 0 ? "'<" : "'[")[1:2]
  let [line_end, col_end] = getpos(a:0 > 0 ? "'>" : "']")[1:2]
  if line_start != line_end
    try
      echoerr 'Refactor single line only'
    endtry
  endif
  let s:lnum = line('.')
  let s:expr = getline(s:lnum)[col_start - 1 : col_end - 1]
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
function! refactor#name_in_project(type, ...) abort " {{{1
  " type is for opfunc
  let [lnum_start, col_start] = getpos(a:0 > 0 ? "'<" : "'[")[1:2]
  let [lnum_end, col_end] = getpos(a:0 > 0 ? "'>" : "']")[1:2]
  let name = getline(line('.'))[col_start - 1 : col_end - 1]
  if &filetype == 'vim'
    let default = matchstr(name, '\v^([^#]+#)*\ze[^#]*$')
  endif

  let newname = input("Refactoring " . name . ":\n> ", default)

  " TODO if vim, move function to appropriate location

  " I don't use 'usetab' in 'switchbuf', so this works
  let starttabnr = tabpagenr()
  execute 'noautocmd $tab split'
  try
    execute 'vimgrep /\<' . name . '\>/j **/*.' . fnamemodify(expand('%'), ':e')
    execute 'cdo s/\<' . name . '\>/' . newname . '/g'
  finally
    quit
    execute 'noautocmd normal!' starttabnr . 'gt'
  endtry
  cwin
endfunction

function! s:update_refactor() abort " {{{1
  let text = getline('.')[ (s:start - 1) : (getcurpos()[2] - 2) ]
  call setline(s:lnum, s:indent . s:prefix . text . s:equals . s:expr)
endfunction

augroup refactor_clear " {{{1
  autocmd!
  autocmd InsertLeave * silent! autocmd! vimrc_refactor_insert
augroup END

let g:refactor_prefix = {'vim': 'let ', 'lua': 'local '}
let g:refactor_equals = {'sh': '='}
