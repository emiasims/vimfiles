if exists('g:loaded_git_dir')
  finish
endif
let g:loaded_git_dir = 1

set noautochdir

augroup vimrc_gitchdir
  autocmd!
  if exists('##DirChanged')
    autocmd DirChanged * let b:autochdir = getcwd()
  endif
  autocmd BufEnter,WinEnter * call git_dir#gotodir()
augroup END

call defer#onidle('call git_dir#gotodir()')
" vim: set ts=2 sw=2 tw=99 et :
