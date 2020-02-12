augroup vimrc_fzf
  autocmd!
  autocmd Filetype fzf setlocal nonumber norelativenumber
augroup END

function! fzf#buffers() abort " {{{1
  let bufs = map(s:buflisted(), 'len(bufname(v:val))')
  let g:fzf_float_width = max(bufs) + 24
  let g:fzf_float_height = len(bufs) + 2
  Buffers
endfunction

function! fzf#floating_win() abort " {{{1
  " See https://github.com/junegunn/fzf.vim/issues/821 for vim implementation.
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
  let fw_height = max([get(g:, 'fzf_float_height', 20), 20])
  let anchor = (lines + fw_height > &lines) ? "SW" : "NW"
  let $FZF_DEFAULT_OPTS = '--layout=' . ((lines + fw_height > &lines) ? 'default' : 'reverse')

  let opts = {
        \ 'relative': 'cursor',
        \ 'row': 1,
        \ 'col': -3,
        \ 'anchor': anchor,
        \ 'width': get(g:, 'fzf_float_width', 120),
        \ 'height': fw_height
        \ }
  silent! unlet g:fzf_float_width g:fzf_float_height

  call nvim_open_win(buf, v:true, opts)
endfunction

function! s:buflisted() abort " {{{2
  return filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"')
endfunction
