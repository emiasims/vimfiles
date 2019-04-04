scriptencoding utf-8


function! s:gitinfo() abort
  " Returns: ' (BRANCH)' or ' '
  let l:statuslinetext = ' '
  if exists('g:loaded_fugitive') && &modifiable
    let l:statuslinetext .= '(' . fugitive#head() . ')'
  endif
  return l:statuslinetext !=# ' ()' ? l:statuslinetext : ' '
endfunction

function! statusline#dirinfo() abort
  " Returns: '(BRANCH)DIR/ ' or 'DIR ' or 'TERM_TITLE '
  if exists('b:term_title')
    let b:stl_dirinfo = ' ' . b:term_title . ' '
    return b:stl_dirinfo
  elseif &filetype ==# 'help'
    let b:stl_dirinfo = ''
    return ''
  endif
  let l:statuslinetext = expand('%:h') !=# '.' ? expand('%:h') . '/' : ''
  let l:statuslinetext = s:gitinfo() . l:statuslinetext . ' '
  let b:stl_dirinfo = l:statuslinetext
  return l:statuslinetext
endfunction

function! statusline#fileinfo() abort
  " Returns: 'filename modified spacer'
  let l:statuslinetext = '%*'
  let l:statuslinetext .= ' %t'
  " Should catch attention when unfocused
  let l:statuslinetext .= &modifiable ? ' %#stlModified#%m' : ' %m'
  let l:statuslinetext .= '%*'
  let l:statuslinetext .= '%='
  return l:statuslinetext
endfunction

function! statusline#encoding()
  " Returns: 'encoding[lineendings]' in the same width as statusline#cursorinfo()
  let l:linedigits = float2nr(ceil(log10(line('$') + 1)))
  let l:stl_typeinfo = (&fileencoding ? &fileencoding : &encoding) . '[' . &fileformat . ']'
  let l:stl_typeinfo .= repeat(' ', 14 + 2 * l:linedigits - len(l:stl_typeinfo))
  return l:stl_typeinfo
endfunction

let s:test = 1

function! statusline#cursorinfo() abort
  " Returns: '%line/lines ☰ lineno/lines : colnum'
  let l:linedigits = float2nr(ceil(log10(line('$') + 1)))
  let l:nwid = '%' . l:linedigits . '.' . l:linedigits
  let l:statuslinetext = ' %2p%% ☰ '  " U+2630
  let l:statuslinetext .= l:nwid . 'l/' . l:nwid .  'L : %02c '
  return l:statuslinetext
endfunction

let s:modes ={
      \ 'n'  : ['%#stlNormalMode#', 'n'],
      \ 'i'  : ['%#stlInsertMode#', 'i'],
      \ 'v'  : ['%#stlVisualMode#', 'v'],
      \ 'V'  : ['%#stlVisualMode#', 'V'],
      \ '' : ['%#stlVisualMode#', 'B'],
      \ 'R'  : ['%#stlReplaceMode#', 'R'],
      \ 's'  : ['%#stlSelectMode#', 's'],
      \ 'S'  : ['%#stlSelectMode#', 'S'],
      \ '' : ['%#stlSelectMode#', 'S'],
      \ 'c'  : ['%#stlTerminalMode#', 'c'],
      \ 't'  : ['%#stlTerminalMode#', 't'],
      \ '-'  : ['%#stlNormalMode#', '-']}

function! statusline#modecolor() abort
  return get(s:modes, mode(), '%*')[0]
endfunction

function! statusline#mode() abort
  return ' ' . get(s:modes, mode(), '-')[1] . ' '
endfunction

function! statusline#errors() abort
  if exists('b:stl_noerr')
    return ''
  endif

  let l:statuslinetext = ''
  " TODO: Currently, message goes away if modified. If we remove the check, we get spammed by
  " the message. Sovled via caching?
  if !&modified && &modifiable && !exists('b:stl_skip_trailing_whitespace') && search('\s$', 'nw')
    let l:statuslinetext .= ' TRAILING WHITESPACE '
  endif

  if &modifiable && search('^\t', 'nw') && search('^  [^\s]', 'nw')
    let l:statuslinetext .= ' MIXED INDENT '
  endif

  " TODO: Once added to neovim, add idx for which element we're on of the list
  let l:statuslinetext .= len(getloclist(0)) > 0 ? ' (ll:' . len(getloclist(0)) . ') ' : ''
  let l:statuslinetext .= len(getqflist()) > 0 ? '(qf:' . len(getqflist()) . ')' : ''
  return l:statuslinetext
endfunction

" vim: set ts=2 sw=2 tw=99 et :
