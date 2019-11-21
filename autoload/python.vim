function! python#text_to_qf(text) abort " {{{1
  let qflist = []
  let i = 0
  while i < len(a:text)
    let errline = matchlist(a:text[i], '\v^ *File "([^"]+)".*line (\d+), in (.*)')
    if len(errline) > 0
      let [fname, lnum, module] = errline[1:3]
      let i += 1
      let desc = matchstr(a:text[i], '^\s*\zs\S.*')
      call add(qflist, {"filename": fnamemodify(fname, ":."), "lnum": lnum, "text": 'in ' . module . ":	" . desc})
    endif
    let i += 1
  endwhile
  call reverse(qflist)
  call setqflist(qflist)
endfunction


function! python#get_repl_errortext() abort " {{{1
  let buf = bufnr()
  " g:repl_bufid from plugin/repl.vim
  try
    execute 'buffer ' . g:repl#bufid
  catch /.*/
    execute 'buffer ' . buf
    return []
  endtry
  normal m'G
  let start = search('^Traceback', 'bW')
  " \vTraceback%(.*\n)%(\s+.*\n)*.*)
  let send = search('^\S', 'W')
  if start == 0 || send == 0
    return []
  endif
  let text = getline(start, send)
  normal ''
  execute 'buffer ' . buf
  return text
endfunction
