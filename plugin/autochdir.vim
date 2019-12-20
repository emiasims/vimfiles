if exists('g:loaded_autochdir')
  finish
endif
let g:loaded_autochdir = 1

set noautochdir

augroup vimrc_autochdir
  autocmd!
  if exists('##DirChanged')
    autocmd DirChanged *.* let b:autochdir = getcwd()
  endif
  autocmd BufEnter *.* call autochdir#gotodir()
augroup END
call defer#onidle('call autochdir#gotodir()')

let s:exceptions = ['~/org', '~/Dropbox/org']

function! autochdir#getdir() abort
  let fname = fnameescape(fnamemodify(bufname(), ':p'))
  let path = finddir('.git', fname . ';')
  if !empty(path)
    return fnamemodify(path, ':p:h:h')
  endif
  for exc in s:exceptions
    if fname =~# '^' . fnameescape(fnamemodify(exc, ':p'))
      return fnameescape(fnamemodify(exc, ':p'))
    endif
  endfor
  return fnamemodify(bufname(), ':p:h')
endfunction

function! autochdir#gotodir() abort
  if !&modifiable || has('vim_starting') || expand('%') =~# '^fugitive'
    return
  endif
  execute 'lcd ' . get(b:, 'autochdir', autochdir#getdir())
endfunction
