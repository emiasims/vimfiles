augroup Example
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call osc52#yank(v:event.regcontents) | endif
augroup END
