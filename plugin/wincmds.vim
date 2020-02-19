function! wincmds#jumporsplit(fname) abort " {{{1
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

function! wincmds#jumporedit(fname) abort " {{{1
  let buf = bufnr(resolve(fnamemodify(a:fname, ':p')))
  if buf < 0 || bufwinnr(buf) < 0
    execute 'edit' a:fname
  else
    execute bufwinnr(buf) . 'wincmd w'
  endif
endfunction

command! -nargs=1 -complete=file JumpOrSplit call wincmds#jumporsplit(<q-args>)
command! -nargs=1 -complete=file JumpOrEdit call wincmds#jumporedit(<q-args>)
