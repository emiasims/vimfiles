set laststatus=2

set statusline=%!statusline#inactive()
augroup vimrc_statusline
  autocmd!
  autocmd WinLeave * setlocal statusline=%!statusline#inactive()
  autocmd WinEnter,BufEnter * setlocal statusline=%!statusline#active()
augroup END

function! statusline#active() abort " {{{1
  let statuslinetext  = statusline#mode(1)
  let statuslinetext .= statusline#dirinfo(1)
  let statuslinetext .= statusline#fileinfo(1)
  let statuslinetext .= '%='
  let statuslinetext .= statusline#temporary()
  let statuslinetext .= statusline#plugins(1)
  let statuslinetext .= statusline#errors(1)
  let statuslinetext .= '%#stlTypeInfo# %y '  " type info
  let statuslinetext .= statusline#cursorinfo(1)
  return statuslinetext
endfunction

function! statusline#inactive() abort " {{{1
  let statuslinetext  = '%#SignColumn# %*%3.3( %)'
  let statuslinetext .= '%{statusline#dirinfo(0)}'
  let statuslinetext .= statusline#fileinfo(0)
  let statuslinetext .= '%='
  let statuslinetext .= '%y '
  let statuslinetext .= '%{statusline#encoding(0)}'
  return statuslinetext
endfunction

function! statusline#plugins(active) abort " {{{1
  if exists('g:loaded_obsession')
    return ObsessionStatus()
  endif
endfunction

function! statusline#temporary() abort " {{{1
  let expr = get(b:, 'stl#tmp', get(g:, 'stl#tmp', ''))
  return !empty(expr) ? eval(expr) . ' ' : ''
endfunction

function! statusline#dirinfo(active) abort " {{{1
  " Returns: '(BRANCH)DIR/ ' or 'DIR ' or 'TERM_TITLE '
  if &filetype ==# 'help'
    return ''
  endif
  let statuslinetext = a:active ? '%#stlDirInfo#' : ''
  if exists('b:term_title')
    let statuslinetext .= ' ' . b:term_title . ' '
  else  " Generally, we want something like (master)dirname/
    let statuslinetext .= s:gitinfo() . (empty(expand('%:h')) ? '' : expand('%:h') . '/') . ' '
  endif
  if a:active
    let statuslinetext .= '%*'
  endif
  return statuslinetext
endfunction

function! s:gitinfo() abort " {{{2
  " Returns: ' (BRANCH)' or ' '
  let statuslinetext = ' '
  if exists('g:loaded_fugitive') && &modifiable
    let statuslinetext .= '(' . fugitive#head() . ')'
  endif
  return statuslinetext !=# ' ()' ? statuslinetext : ' '
endfunction

function! statusline#fileinfo(active) abort " {{{1
  " Returns: 'filename modified spacer'
  let statuslinetext = ' %t'
  " Should catch attention when unfocused
  if a:active
    let statuslinetext .= &modifiable ? '%#stlModified#' : ''
  endif
  let statuslinetext .= ' %m'
  let statuslinetext .= '%*'
  return statuslinetext
endfunction

function! statusline#encoding(active) " {{{1
  " Returns: 'encoding[lineendings]' in the same width as statusline#cursorinfo()
  let linedigits = float2nr(ceil(log10(line('$') + 1)))
  let stl_typeinfo = (&fileencoding ? &fileencoding : &encoding) . '[' . &fileformat . ']'
  let stl_typeinfo .= repeat(' ', 14 + 2 * linedigits - len(stl_typeinfo))
  return stl_typeinfo
endfunction

function! statusline#cursorinfo(active) abort " {{{1
  " Returns: '%line/lines ☰ lineno/lines : colnum'
  let linedigits = float2nr(ceil(log10(line('$') + 1)))
  let nwid = '%' . linedigits . '.' . linedigits
  let statuslinetext = s:modecolor() . ' %2p%% ☰ '  " U+2630
  let statuslinetext .= nwid . 'l/' . nwid .  'L : %02c %*'
  return statuslinetext
endfunction

function! s:modecolor() abort " {{{1
  return get(s:modes, mode(), '%*')[0]
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

function! statusline#mode(active) abort " {{{1
  return ' ' . s:modecolor() . '%3.3( ' . get(s:modes, mode(), '-')[1] . ' %)'
endfunction

function! statusline#errors(active) abort " {{{1
  if exists('b:stl_noerr') || !a:active
    return ''
  endif

  let statuslinetext = '%#stlErrorInfo#'
  if !has('vim_starting')
    if !&modified && &modifiable && !exists('b:stl_skip_trailing_whitespace') && search('\s$', 'nw')
      let statuslinetext .= ' TRAILING WHITESPACE '
    endif

    if &modifiable && search('^\t', 'nw', line('.') + 1) && search('^  [^\s]', 'nw')
      let statuslinetext .= ' MIXED INDENT '
    endif
  endif

  " TODO: Once added to neovim, add idx for which element we're on of the list
  let statuslinetext .= len(getloclist(0)) > 0 ? ' (ll:' . len(getloclist(0)) . ') ' : ''
  let statuslinetext .= len(getqflist()) > 0 ? '(qf:' . len(getqflist()) . ')' : ''
  let statuslinetext .= '%*'
  return statuslinetext
endfunction
