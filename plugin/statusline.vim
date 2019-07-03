scriptencoding utf-8

if exists('g:loaded_statusline')
  finish
endif
let g:loaded_statusline = 1

set laststatus=2

" TODO: come up with better standard for how where (here vs autoload) things are
function! Statusline_active() abort
  let l:statuslinetext  = ' %3.3('.statusline#modecolor().statusline#mode().'%)'
  let l:statuslinetext .= '%#stlDirInfo#'
  let l:statuslinetext .= statusline#dirinfo()
  let l:statuslinetext .= '%*'
  let l:statuslinetext .= statusline#fileinfo()
  let l:statuslinetext .= '%*'
  let l:statuslinetext .= statusline#plugins()
  let l:statuslinetext .= '%#stlErrorInfo#'
  let l:statuslinetext .= statusline#errors()
  let l:statuslinetext .= '%#stlTypeInfo# '
  let l:statuslinetext .= '%y '
  let l:statuslinetext .= statusline#modecolor()
  let l:statuslinetext .= statusline#cursorinfo()
  return l:statuslinetext
endfunction

function! Statusline_inactive() abort
  let l:statuslinetext  = '%#SignColumn# %*%3.3( %)'
  let l:statuslinetext .= '%{statusline#dirinfo()}'
  let l:statuslinetext .= statusline#fileinfo()
  let l:statuslinetext .= '%y '
  let l:statuslinetext .= '%{statusline#encoding()}'
  return l:statuslinetext
endfunction

set statusline=%!Statusline_inactive()
augroup vimrc_statusline
  autocmd!
  autocmd WinLeave * setlocal statusline=%!Statusline_inactive()
  autocmd WinEnter,BufEnter * setlocal statusline=%!Statusline_active()
augroup END
