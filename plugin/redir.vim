" https://gist.github.com/romainl/eae0a260ab9c135390c30cd370c20cd7
function! s:scratch(cmd) abort range
  for win in range(1, winnr('$'))
    if getwinvar(win, 'scratch')
      execute win . 'windo close'
    endif
  endfor
  vnew
  " SmartSplit new
  let w:scratch = 1
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
  call setline(1, redir#from(a:cmd, a:firstline, a:lastline))
endfunction

function! redir#from(cmd, ...) abort
  if a:cmd =~ '^!'
    let cmd = a:cmd =~' %'
          \ ? matchstr(substitute(a:cmd, ' %', ' ' . expand('%:p'), ''), '^!\zs.*')
          \ : matchstr(a:cmd, '^!\zs.*')
    if !exists('a:1')
      let output = systemlist(cmd)
    else  " range
      let [rstart, rend] = [a:1, get(a:, 2, a:1)]
      let joined_lines = join(getline(rstart, end), '\n')
      let cleaned_lines = substitute(shellescape(joined_lines), "'\\\\''", "\\\\'", 'g')
      let output = systemlist(cmd . " <<< $" . cleaned_lines)
    endif
  else
    let output = split(execute(a:cmd), "\n")
  endif
  return output
endfunction

command! -nargs=1 -complete=command -bar -range Redir silent call s:scratch(<q-args>)
