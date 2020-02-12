function! wincmds#split(fname) abort " {{{1
  let buf = bufnr(resolve(fnamemodify(a:fname, ':p')))
  if buf < 0 || bufwinnr(buf) < 0
    execute 'vertical split' a:fname
    if winwidth(0) < &colorcolumn + &foldcolumn + &number * &numberwidth
      quit
      execute 'split' a:fname
    endif
  else
    execute bufwinnr(buf) . 'wincmd w'
  endif
endfunction

command! -nargs=1 -complete=file SmartSplit call wincmds#split(<q-args>)
