function! python#text_to_qf(text) abort " {{{1
  let qflist = []
  let text = split(join(a:text, ''), '\s*\zeFile')
  for line in text
    let errline = matchlist(line, '\v^File "(.+)".*line (\d+), in (\S*)\s*(\S.*)')
    " echo 'line:	' line
    " echo 'errline:	' errline
    if len(errline) > 0
      let [fname, lnum, module, desc] = errline[1:4]
      let text = 'in ' . module . ":	" . desc
      call add(qflist, {"filename": fnamemodify(fname, ":~:."), "lnum": lnum, "text": text})
    endif
  endfor
  call setqflist(qflist)
endfunction

function! python#get_repl_errortext() abort " {{{1
  if !exists('g:repl#bufid') || g:repl#bufid == -1
    throw 'Repl not set'
  endif

  let buf = bufnr()
  execute 'buffer' g:repl#bufid
  try
    normal m`G
    let start = search('^Traceback', 'bW')
    let send = search('^\w*Error:', 'W')
    if start == 0 || send == 0
      return ''
    endif
    let text = getline(start, send)
    normal ``
  finally
    execute 'buffer ' . buf
  endtry
  return text
endfunction
