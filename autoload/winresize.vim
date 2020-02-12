function! winresize#right(increment) abort
  execute 'vert resize ' . (winnr() == winnr('l') ? '-' : '+') . a:increment
endfunction

function! winresize#left(increment) abort
  execute 'vert resize ' . (winnr() != winnr('l') ? '-' : '+') . a:increment
endfunction

function! winresize#up(increment) abort
  execute 'resize ' . (winnr() != winnr('j') ? '-' : '+') . a:increment
endfunction

function! winresize#down(increment) abort
  execute 'resize ' . (winnr() == winnr('j') ? '-' : '+') . a:increment
endfunction
