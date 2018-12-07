scriptencoding utf-8

function! statusline#gitinfo() abort
  let l:statuslinetext = ' '
  if exists('g:loaded_fugitive') && &modifiable
    let l:statuslinetext .= '(' . fugitive#head() . ')'
  endif
  return l:statuslinetext !=# ' ()' ? l:statuslinetext : ' '
endfunction

function! statusline#dirinfo() abort
  if exists('b:term_title')
    return ' ' . b:term_title . ' '
  endif
  let l:statuslinetext = expand('%:h')
  if l:statuslinetext !=# '.'
    let l:statuslinetext .= '/'
  else
    let l:statuslinetext = ''
  endif
  return statusline#gitinfo() . l:statuslinetext . ' '
endfunction

function! statusline#fileinfo() abort
  " TODO: modified changes color. choose %#HLname# based on &modified
  let l:statuslinetext = ' %t'
  let l:statuslinetext .= ' %m'
  let l:statuslinetext .= '%='
  let l:statuslinetext .= '%y '
  return l:statuslinetext
endfunction

function! statusline#typeinfo() abort
  let l:statuslinetext = ' %{&fileencoding?&fileencoding:&encoding}'
  let l:statuslinetext .= '[%{&fileformat}] '
  return l:statuslinetext
endfunction

function! statusline#bufinfo() abort
  let l:statuslinetext = ' %p%% ☰ '  " U+2630
  let l:statuslinetext .= '%l/%L : %c '
  return l:statuslinetext
endfunction

let s:modes ={
      \ 'n'  : ['%#stlNormal#', 'n'],
      \ 'i'  : ['%#stlInsert#', 'i'],
      \ 'v'  : ['%#stlVisual#', 'v'],
      \ 'V'  : ['%#stlVisual#', '☴'],
      \ '' : ['%#stlVisual#', '◧'],
      \ 'R'  : ['%#stlReplace#', 'R'],
      \ 's'  : ['%#stlSelect#', 's'],
      \ 'S'  : ['%#stlSelect#', 'S'],
      \ '' : ['%#stlSelect#', 'S'],
      \ 'c'  : ['%#stlTerminal#', '⌘'],
      \ 't'  : ['%#stlTerminal#', '▣'],
      \ '-'  : ['%#stlNormal#', '-']}

function! statusline#modecolor() abort
  return get(s:modes, mode(), '%*')[0]
endfunction

function! statusline#mode() abort
  return ' ' . get(s:modes, mode(), '-')[1] . ' '
endfunction

function! statusline#errors() abort
  " Trailing whitespace
  " quickfix, location-list
  " mixed indentation
  return ''
endfunction

" vim: set ts=2 sw=2 tw=99 et :
