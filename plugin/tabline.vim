if has('nvim')
  finish
endif

function! Tabline() abort " {{{1
  let tabline = []
  for tabnr in range(1, tabpagenr('$'))
    let is_current = tabnr == tabpagenr()
    let bgc = is_current ? '%#TabLineSel#' : '%#TabLine#'
    let text = is_current ? '%#TabLineSelNumber#' : '%#TabLineNumber#'
    let text .= '%' . tabnr . 'T ' . tabnr . ' '
    let text .= bgc
    let text .= s:get_tab_text(tabnr, bgc)
    call add(tabline, text)
  endfor
  return join(tabline, '%#TabLine# ') . '%#TabLineFill#%T' .
        \ (tabpagenr('$') > 1 ? '%=%#TabLineFill#%999XX ' : '')
endfunction

function! s:get_tab_text(tabnr, bg) abort " {{{1
  let wintree = winlayout(a:tabnr)
  let text = s:gettext(wintree, 'leaf', a:bg)
  let text = substitute(text, '  \+', ' ', 'g')      " Remove double space
  let text = substitute(text, '\v^ +| +$', '', 'g')  " Remove spaces from ends
  return text
endfunction

let s:add_dir = { 'init.lua': 1, 'base.lua': 1 }

function! s:gettext(tree, prev, bg) abort " {{{2
  " a:tree[0] is always type, a:tree[1] is either a number or a list
  if a:tree[0] == 'leaf'
    let name = fnamemodify(bufname(winbufnr(a:tree[1])), ':t')
    if empty(name)
      let name = "[Scratch]"
    endif
    if get(s:add_dir, name, 0)
      let name = substitute(bufname(winbufnr(a:tree[1])), '\v^%(.*/)?([^/]+)/([^/]+)$', '\1➔\2', '')
    endif
    if a:tree[1] == win_getid()
      let name = '%#TabLineWin#' . name . '%#TabLineSel#'
    endif
  elseif a:tree[0] == 'row'
    let name = join(map(copy(a:tree[1]), 's:gettext(v:val, "row", a:bg)'), '%#TabLine#|' .. a:bg)
    if a:prev == 'col'
      let name = ' ' . name . ' '
    endif
  elseif a:tree[0] == 'col'
    let name = join(map(copy(a:tree[1]), 's:gettext(v:val, "col", a:bg)'), '%#TabLine#/' .. a:bg)
    if a:prev == 'row'
      let name = ' ' . name . ' '
    endif
  endif
  return name
endfunction

set tabline=%!Tabline()
