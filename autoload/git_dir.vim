function! git_dir#getdir() abort
  let l:gitroot = get(b:, 'git_dir', '')  " from vim-fugitive
  let l:gitroot = resolve(substitute(l:gitroot, '/\.git$', '', ''))
  if !empty(l:gitroot)
    return l:gitroot
  endif
  let l:filedir = resolve(expand('%:p:h'))
  if empty(l:filedir)
    let l:filedir = resolve(getcwd())
  endif
  return l:filedir
endfunction

function! git_dir#gotodir() abort
  if !&modifiable || has('vim_starting')
    return
  endif

  let b:autochdir = get(b:, 'autochdir', git_dir#getdir())
  execute 'lcd ' . b:autochdir
endfunction

" vim: set ts=2 sw=2 tw=99 et :
