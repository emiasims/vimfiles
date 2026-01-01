augroup vimrc_general
  autocmd!
  au BufWinLeave * if empty(&buftype) && &modifiable && !empty(expand('%')) | mkview | endif
  au BufWinEnter * if empty(&buftype) && &modifiable && !empty(expand('%')) | silent! loadview | endif

  autocmd WinEnter,FocusGained * silent! checktime

  autocmd WinLeave,BufLeave,FocusLost * if &buftype == '' && &modifiable && filereadable(bufname('%')) | silent! lockmarks update | endif

  " Update filetype on save if empty
  autocmd BufWritePost * ++nested if empty(&filetype) | unlet! b:ftdetect | filetype detect | endif

  " When editing a file, always jump to the last known cursor position, if valid.
  autocmd BufReadPost *
        \  if &ft !~ '^git\c' && ! &diff && line("'\"") > 0 && line("'\"") <= line("$")
        \|   execute 'normal! g`"zvzz'
        \| endif

  " Disable paste and/or update diff when leaving insert mode
  autocmd InsertLeave * if &paste | setlocal nopaste | echo 'nopaste' | endif
  autocmd InsertLeave * if &diff | diffupdate | endif

  autocmd WinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline

  autocmd BufWritePre *
        \  if &buftype == '' && expand('<afile>:p') =~# '^' .. escape($HOME, '\') .. '/'
        \|   call mkdir(expand("<afile>:p:h"), "p")
        \| endif

  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif

  autocmd FileType qfreplace setlocal nofoldenable
  autocmd FileType sh let g:is_bash=1
  autocmd FileType sh let g:sh_fold_enabled=5
  autocmd BufRead * if empty(&filetype) | set commentstring=#%s | endif
augroup END
