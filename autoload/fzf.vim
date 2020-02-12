augroup vimrc_fzf
  autocmd!
  autocmd Filetype fzf setlocal nonumber norelativenumber
augroup END

function! fzf#floating_win()
  let buf = nvim_create_buf(v:false, v:true)
  call setbufvar(buf, '&signcolumn', 'no')

  " get 'absolute' line number. starts at 1 for tabline, adds 1 for status lines
  let window = winnr()
  noautocmd 9wincmd k
  let lines = 1
  while winnr() != window
    let lines += nvim_win_get_height(0) + 1
    noautocmd wincmd j
  endwhile
  let lines += winline()

  " default to opening downward, but open upward if we're too far down.
  let fw_height = 18
  let anchor = (lines + fw_height > &lines) ? "SW" : "NW"
  let $FZF_DEFAULT_OPTS = '--layout=' . ((lines + fw_height > &lines) ? 'default' : 'reverse')

  let opts = {
        \ 'relative': 'cursor',
        \ 'row': 1,
        \ 'col': -3,
        \ 'anchor': anchor,
        \ 'width': 120,
        \ 'height': fw_height
        \ }

  call nvim_open_win(buf, v:true, opts)
endfunction
