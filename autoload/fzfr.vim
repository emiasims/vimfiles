" fzfr: fuzzy friend
augroup vimrc_fzf
  autocmd!
  autocmd Filetype fzf setlocal nonumber norelativenumber
augroup END

function! fzfr#buffers() abort " {{{1
  let bufs = filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"')
  let bufs = map(bufs, 'len(bufname(v:val))')
  let g:fzf#size = [max(bufs) + 24, len(bufs) + 2]
  Buffers
endfunction

function! fzfr#setsize(width, height) abort " {{{1
  let g:fzf#size = [str2nr(a:width), str2nr(a:height)]
endfunction

" TODO: Allow args for buffers & subsequent functions.
" TODO: big floating window when wanted.
" For :Commits, :Gfiles?, :BCommits

function! fzfr#floating_win() abort " {{{1
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

  let [wid, hei] = get(g:, 'fzf#size', [120, 20])


  " default to opening downward, but open upward if we're too far down.
  let hei = min([hei, 20])
  let anchor = (lines + hei > &lines) ? "SW" : "NW"
  let $FZF_DEFAULT_OPTS = '--layout=' . ((lines + hei > &lines) ? 'default' : 'reverse')

  let opts = {
        \ 'relative': 'cursor',
        \ 'row': 1,
        \ 'col': -3,
        \ 'anchor': anchor,
        \ 'width': wid,
        \ 'height': hei
        \ }
  silent! unlet g:fzf#size

  call nvim_open_win(buf, v:true, opts)
endfunction
