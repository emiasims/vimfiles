function! wincmds#smartsplit(fname, ...) abort " {{{1
  let cmdifnovert = get(a:, 1, 'split')
  let buf = bufnr(resolve(fnamemodify(a:fname, ':p')))
  execute 'vertical split' a:fname
  if winwidth(0) < &colorcolumn + &foldcolumn + &number * &numberwidth
    quit
    execute cmdifnovert a:fname
  endif
endfunction

function! wincmds#jumporsplit(fname) abort " {{{1
  let buf = bufnr(resolve(fnamemodify(a:fname, ':p')))
  if buf < 0 || bufwinnr(buf) < 0
    call wincmds#smartsplit(a:fname)
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

function! wincmds#jumpsplitoredit(fname) abort " {{{1
  let buf = bufnr(resolve(fnamemodify(a:fname, ':p')))
  if buf < 0 || bufwinnr(buf) < 0
    call wincmds#smartsplit(a:fname, 'edit')
  else
    execute bufwinnr(buf) . 'wincmd w'
  endif
endfunction

command! -bar -nargs=1 -complete=file SmartSplit call wincmds#smartsplit(<q-args>)
command! -bar -nargs=1 -complete=file JumpOrSplit call wincmds#jumporsplit(<q-args>)
command! -bar -nargs=1 -complete=file JumpOrEdit call wincmds#jumporedit(<q-args>)
command! -bar -nargs=1 -complete=file JumpSplitOrEdit call wincmds#jumpsplitoredit(<q-args>)
