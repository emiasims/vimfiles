function! winresize#go(vert, diff) abort
  let diff = winnr() == winnr(a:vert ? 'j' : 'l') ? a:diff : -a:diff
  execute (a:vert ? '' : 'vert ') .. 'resize ' .. (diff > 0 ? '+' : '') .. diff
endfunction
