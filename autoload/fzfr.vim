" fzfr: fuzzy friend
augroup vimrc_fzf
  autocmd!
  autocmd Filetype fzf setlocal nonumber norelativenumber
augroup END

function! fzfr#buffers() abort " {{{1
  let bufs = filter(range(1, bufnr('$')), 'buflisted(v:val) && getbufvar(v:val, "&filetype") != "qf"')
  let width = max(map(bufs, 'len(bufname(v:val))')) + 16
  let height = max([len(bufs) + 2, 15])
  let g:fzf#size = [width, height]
  Buffers
endfunction

function! fzfr#tags(...) abort " {{{1
  let s:tags = taglist(get(a:, 1, '.'))
  if len(s:tags) == 1
    execute 'JumpSplitOrEdit' s:tags[0].filename
    silent execute s:tags[0].cmd
  elseif len(s:tags) > 1
    let l:tags = s:pretty(s:tags)
    call fzfr#setsize(max(map(deepcopy(l:tags), 'strdisplaywidth(v:val)')) + 5, min([len(l:tags), 20]))
    call fzf#run(fzf#wrap({'source': l:tags, 'sink': funcref('s:tag_sink')}))
  else
    echoerr 'No tags found'
  endif
endfunction

function! s:pretty(tags) abort " {{{2
  let tags = map(copy(a:tags), {i, t -> [t.name, has_key(a:tags[i], 'class') ? 'Class:' . t.class : '', fnamemodify(t.filename, ':~:.')]})
  let widths = map(deepcopy(tags), {i, t -> map(t, 'strdisplaywidth(v:val)')})
  let strwid = widths[0]
  for ws in widths[1:]
    call map(strwid, {col, mw -> (ws[col] > mw) ? ws[col] : mw})
  endfor
  let cols = range(len(strwid))
  for ix in range(len(tags))
    let text = (ix + 1) . ': '
    for col in cols[:-2]
      let text .= tags[ix][col] . repeat(' ', strwid[col] - strdisplaywidth(tags[ix][col])) . "\t"
    endfor
    let tags[ix] = text . tags[ix][-1]
  endfor
  return tags
endfunction

function! s:tag_sink(selection) abort " {{{2
  let tag = s:tags[split(a:selection, ':')[0] - 1]
  execute 'JumpSplitOrEdit' tag.filename
  silent execute tag.cmd
  unlet s:tags
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
