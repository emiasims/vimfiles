function! s:is_edge_window(direction) abort
  let l:win = winnr()
  execute 'wincmd ' . a:direction
  let l:edge_window = winnr() == l:win
  if !l:edge_window
    execute l:win . 'wincmd w'
  endif
  return l:edge_window
endfunction

function! winresize#right(increment) abort
  execute 'vert resize ' . (s:is_edge_window('l') ? '-' : '+') . a:increment
endfunction

function! winresize#left(increment) abort
  echom 'vert resize ' . (!s:is_edge_window('l') ? '-' : '+') . a:increment
  execute 'vert resize ' . (!s:is_edge_window('l') ? '-' : '+') . a:increment
endfunction

function! winresize#up(increment) abort
  execute 'resize ' . (!s:is_edge_window('j') ? '-' : '+') . a:increment
endfunction

function! winresize#down(increment) abort
  execute 'resize ' . (s:is_edge_window('j') ? '-' : '+') . a:increment
endfunction
