function! s:lua(filename)
  let names = split(a:filename, '/')
  if names[0] == 'tests'
    let names[-1] = names[-1][:-10] .. '.lua'
    return join(['lua'] + names[1:], '/')
  endif

  let names[-1] = names[-1][:-5] .. '_spec.lua'
  return join(['tests'] + names[1:], '/')
endfunction

function! testing#get_alt()
  " assuming cwd is project dir (see autochdir)
  if &filetype == 'lua'
    return s:lua(expand('%'))
  endif
  throw "Can't find alt for "
endfunction

function! testing#prompt()
  " assuming cwd is project dir (see autochdir)
  let alt = testing#get_alt()
  if filereadable(alt) || input(printf('File "%s" does not exist. Create it? ', alt), 'y') =~? '^y'
    exe 'edit ' .. alt
  endif
endfunction
