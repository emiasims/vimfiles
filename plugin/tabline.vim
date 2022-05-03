" 1. make secondary tabline -- float/popup window
" 2. Get window names, and alternates
" 3. update on changing buffers, windows, or tabs.
" 4. Highlight group for current window in the current tab
" 3. autocmd when buffer dies, it echos a message for how to open it back up
" Delimiter specification options

" ╟╴1 filenamew1.ext | filenamew2.ext ╟╴2 filename w1 ║
" ║    altnamew1.ext |  altnamew2.ext ║    altname w1 ║

" ╟╴1 filenamew1.ext # alt.ext | filenamew2.ext # altname ╟╴2 filename w1 ║

" See: winlayout, use that + alt of that one lines 1 and 2 for formatting

" ['row', [['leaf', 1000], ['col', [['leaf', 1021], ['row', [['leaf', 1020], ['leaf', 1022]]]]]]]
" reduce to


" 1: win| win/ win|win ║

" ['row', [['leaf', 1000], ['col', [['leaf', 1073], ['leaf', 1072]]], ['col', [['leaf', 1021], ['row', [['leaf', 1020], ['leaf', 1022]]]]]]]

" tabline.vim│ tabline.vim╱tabline.vim│ tabline.vim╱ tabline.vim│tabline.vim

function! Tabline() abort " {{{1
  let tabline = []
  for tabnr in range(1, tabpagenr('$'))
    let text = (tabnr == tabpagenr() ? '%#TabLineSelNumber#' : '%#TabLineNumber#')
    let text .= '%' . tabnr . 'T ' . tabnr . ' '
    let text .= (tabnr == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')
    let text .= s:get_tab_text(tabnr)
    call add(tabline, text)
  endfor
  return join(tabline, '%#TabLine# ') . '%#TabLineFill#%T' .
        \ (tabpagenr('$') > 1 ? '%=%#TabLineFill#%999XX ' : '')
endfunction

function! s:get_tab_text(tabnr) abort " {{{1
  let wintree = winlayout(a:tabnr)
  let text = s:gettext(wintree, 'leaf')
  let text = substitute(text, '  \+', ' ', 'g')      " Remove double space
  let text = substitute(text, '\v^ +| +$', '', 'g')  " Remove spaces from ends
  return text
endfunction

let s:add_dir = { 'init.lua': 1, 'base.lua': 1 }

function! s:gettext(tree, prev) abort " {{{2
  " a:tree[0] is always type, a:tree[1] is either a number or a list
  if a:tree[0] == 'leaf'
    let name = fnamemodify(bufname(winbufnr(a:tree[1])), ':t')
    if get(s:add_dir, name, 0)
      let name = substitute(bufname(winbufnr(a:tree[1])), '\v^%(.*/)?([^/]+)/([^/]+)$', '\1➔\2', '')
    endif
    if a:tree[1] == win_getid()
      let name = '%#TabLineWin#' . name . '%#TabLineSel#'
    endif
  elseif a:tree[0] == 'row'
    let name = join(map(copy(a:tree[1]), 's:gettext(v:val, "row")'), '|')
    if a:prev == 'col'
      let name = ' ' . name . ' '
    endif
  elseif a:tree[0] == 'col'
    let name = join(map(copy(a:tree[1]), 's:gettext(v:val, "col")'), '/')
    if a:prev == 'row'
      let name = ' ' . name . ' '
    endif
  endif
  return name
endfunction

set tabline=%!Tabline()
