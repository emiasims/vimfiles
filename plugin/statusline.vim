scriptencoding utf-8

if exists('g:loaded_statusline')
  finish
endif
let g:loaded_statusline = 1

set laststatus=2

function! Statusline_active() abort
  let l:statuslinetext  = ' %3.3('.statusline#modecolor().statusline#mode().'%)'
  let l:statuslinetext .= '%#stlDirInfo#'
  let l:statuslinetext .= statusline#dirinfo()
  let l:statuslinetext .= '%*'
  let l:statuslinetext .= statusline#fileinfo()
  let l:statuslinetext .= '%#stlTypeInfo#'
  if exists('b:stl_file_info')
    let l:statuslinetext .= statusline#typeinfo()
  endif
  let l:statuslinetext .= statusline#modecolor()
  let l:statuslinetext .= statusline#bufinfo()
  let l:statuslinetext .= '%#stlErrorInfo#'
  " let l:statuslinetext .= statusline#errors()  " TODO
  return l:statuslinetext
endfunction

function! Statusline_inactive() abort
  let l:statuslinetext  = '%#SignColumn# %*%3.3( %)'
  let l:statuslinetext .= statusline#gitinfo()
  let l:statuslinetext .= statusline#fileinfo()
  let l:statuslinetext .= statusline#typeinfo()
  return l:statuslinetext
endfunction

set statusline=%!Statusline_inactive()
augroup vimrc_statusline
  autocmd!
  autocmd WinEnter,BufEnter * setlocal statusline=%!Statusline_active()
  autocmd WinLeave * setlocal statusline=%!Statusline_inactive()
augroup END

" vim: set ts=2 sw=2 tw=99 et :
