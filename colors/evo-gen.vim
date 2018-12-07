" 'evolution.vim' -- Vim color scheme.
" Author:       Matt Simmons (mtszyk@gmail.com)
" Last Change:  2018-06-21

hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'evolution'

" define variable, reload vimrc to use
" if exists('g:defhighlightmap')
map <F9> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
      \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name")
      \ . '> lo<' . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
" endif


" highlight function and commmand {{{

" This function is just to allow fg=DICT for cterm and gui.
" I think it helps make the colorscheme more readable and easily edited.
" These work:
" Highlight Normal    bg=s:bg_0    fg=s:fg_1    attr=NONE
" Highlight Normal    ctermbg=s:bg_0[0]  guitermbg=s:bg_0[1]   fg=s:fg_1

let g:color_commands = []
function! s:hi(group, ...) abort
  let l:cmd = 'highlight ' . a:group
  for l:arg in a:000
    let l:term = split(l:arg, '=')
    let l:key = l:term[0]
    " If the key is fg or bg, map both cterm and gui colors
    if l:key ==# 'fg' || l:key ==# 'bg'
      if len(split(l:term[1], ':')) == 2
        execute 'let l:tcolor = ' . l:term[1] . '[0]'
        execute 'let l:gcolor = ' . l:term[1] . '[1]'
      else
        let l:tcolor = l:term[1]
        let l:gcolor = l:term[1]
      endif
      let l:cmd .= ' cterm' . l:key . '=' . l:tcolor
      let l:cmd .= ' gui' . l:key . '=' . l:gcolor
    elseif l:key ==# 'attr'
      if len(split(l:term[1], ':')) == 2
        execute 'let l:attr = ' . l:term[1]
      else
        let l:attr = l:term[1]
      endif
      let l:cmd .= ' cterm=' . l:attr . ' gui=' . l:attr
    else
      " otherwise, check if still needs to be evaluated
      if len(split(l:term[1], ':')) == 2
        execute 'let l:value = ' . l:term[1]
      else
        let l:value = l:term[1]
      endif
      let l:cmd .= ' ' . l:key . '=' . l:value
    endif
  endfor
  call add(g:color_commands, l:cmd)
  execute l:cmd
endfunction

command! -nargs=+ -complete=highlight Highlight call s:hi(<f-args>)

" }}}
" color definitions {{{
" OLD
let s:dark0  = [234, '#1d2021']
let s:dark1  = [235, '#282828']
let s:dark2  = [237, '#3c3836']
let s:dark3  = [239, '#504945']
let s:dark4  = [59 , '#665c54']

let s:light0 = [187, '#d5c4a1']
let s:light1 = [144, '#bdae93']
let s:light2 = [138, '#a89984']
let s:light3 = [102, '#948774']

let s:aqua   = [73 , '#72b7b5']
let s:laqua  = [116, '#84d4d2']
let s:blue   = [73 , '#6fa3a6']
let s:lblue  = [108, '#83a598']
let s:green  = [65 , '#679a69']
let s:lgreen = [65 , '#91ba93']
let s:violet = [139, '#b48ead']

let s:red    = [167, '#D84A44']
let s:orange = [166, '#d65d0e']
let s:orange = [173, '#c7743e']
let s:yellow = [172, '#d79921']

" }}}
" True and 256 colors {{{
if ($TERM =~# '256' || &t_Co >= 256) || has('gui_running')

  Highlight Normal           fg=s:light0 bg=s:dark0  attr=NONE
  set background=dark

  Highlight LineNr           fg=s:dark3  bg=s:dark0  attr=NONE
  Highlight SignColumn       fg=s:dark1  bg=s:dark0  attr=NONE
  Highlight FoldColumn       fg=s:dark3  bg=s:dark0  attr=NONE
  Highlight MatchParen       fg=s:aqua   bg=s:dark3  attr=NONE

  Highlight Statement        fg=s:lblue  bg=NONE     attr=bold
  Highlight PreProc          fg=s:lblue  bg=NONE     attr=NONE
  Highlight Function         fg=s:blue   bg=NONE     attr=NONE
  Highlight String           fg=s:green  bg=NONE     attr=NONE
  Highlight Number           fg=s:violet bg=NONE     attr=NONE

  Highlight Folded           fg=s:light3 bg=s:dark1  attr=NONE
  Highlight Comment          fg=s:light3 bg=NONE     attr=italic
  Highlight Identifier       fg=s:lgreen bg=NONE     attr=NONE
  Highlight Type             fg=s:lblue  bg=NONE     attr=NONE
  Highlight Special          fg=s:light0 bg=NONE     attr=NONE
  Highlight Constant         fg=s:light0 bg=NONE     attr=NONE
  Highlight Error            fg=s:red    bg=NONE     attr=bold
  Highlight Todo             fg=s:yellow bg=NONE     attr=bold
  Highlight NonText          fg=s:dark2  bg=NONE     attr=NONE

  Highlight WildMenu         fg=s:aqua   bg=s:dark3  attr=NONE
  Highlight PMenu            fg=s:light0 bg=s:dark1  attr=NONE
  Highlight PmenuSbar        fg=s:light0 bg=s:dark1  attr=NONE
  Highlight PMenuSel         fg=s:aqua   bg=s:dark2  attr=NONE
  Highlight PmenuThumb       fg=s:light2 bg=s:dark2  attr=NONE

  Highlight ErrorMsg         fg=s:light0 bg=s:red    attr=NONE
  Highlight ModeMsg          fg=s:light0 bg=NONE     attr=NONE
  Highlight MoreMsg          fg=s:light0 bg=NONE     attr=NONE
  Highlight Question         fg=s:light0 bg=NONE     attr=NONE
  Highlight WarningMsg       fg=s:red    bg=s:dark0  attr=NONE
  Highlight TabLine          fg=s:light3 bg=s:dark1  attr=NONE
  Highlight TabLineFill      fg=s:light3 bg=s:dark1  attr=NONE
  Highlight TabLineSel       fg=s:light3 bg=s:dark3  attr=NONE
  Highlight Cursor           fg=s:dark0  bg=s:light0 attr=NONE
  Highlight CursorColumn     fg=NONE     bg=s:dark1  attr=NONE
  Highlight CursorLineNr     fg=s:aqua    bg=s:dark0  attr=NONE
  Highlight CursorLine       fg=NONE     bg=s:dark1  attr=NONE
  Highlight ColorColumn      fg=NONE     bg=s:dark1  attr=NONE
  Highlight StatusLine       fg=s:light1 bg=s:dark1  attr=NONE
  Highlight StatusLineNC     fg=s:light3 bg=s:dark2  attr=NONE
  Highlight StatusLineTerm   fg=s:aqua   bg=s:dark2  attr=NONE
  Highlight StatusLineTermNC fg=s:light0 bg=s:dark1  attr=NONE

  Highlight Visual           fg=NONE     bg=s:dark2  attr=NONE
  Highlight VisualNOS        fg=NONE     bg=s:dark2  attr=NONE
  Highlight VertSplit        fg=s:dark2  bg=NONE  attr=NONE
  Highlight SpecialKey       fg=s:light3  bg=NONE     attr=NONE
  Highlight Title            fg=s:light0 bg=NONE     attr=NONE
  Highlight DiffAdd          fg=s:green  bg=s:dark1  attr=reverse
  Highlight DiffChange       fg=s:yellow bg=s:dark1  attr=reverse
  Highlight DiffDelete       fg=s:red    bg=s:dark1  attr=reverse
  Highlight DiffText         fg=s:lblue  bg=s:dark1  attr=reverse
  Highlight IncSearch        fg=s:dark1  bg=s:orange   attr=NONE
  Highlight Search           fg=s:dark1  bg=s:orange   attr=NONE
  Highlight Directory        fg=s:aqua   bg=NONE     attr=NONE
  Highlight SpecialChar      fg=s:yellow bg=NONE     attr=NONE
  Highlight SpecialComment   fg=s:aqua   bg=NONE     attr=italic

  Highlight stlTypeInfo      fg=s:blue   bg=s:dark0  attr=NONE
  Highlight stlErrorInfo     fg=s:dark0  bg=s:orange attr=bold
  Highlight stlDirInfo       fg=s:laqua   bg=s:dark2  attr=NONE

  Highlight stlNormal        fg=s:yellow bg=s:dark3  attr=bold
  Highlight stlInsert        fg=s:dark0  bg=s:green  attr=bold
  Highlight stlVisual        fg=s:dark0  bg=s:orange attr=NONE
  Highlight stlReplace       fg=s:dark0  bg=s:blue   attr=NONE
  Highlight stlSelect        fg=s:dark0  bg=s:blue   attr=NONE
  Highlight stlTerminal      fg=s:violet bg=s:dark3  attr=NONE

  Highlight debugPC          bg=s:blue
  Highlight debugBreakpoint  bg=s:red

  if has('gui_running')
    Highlight SpellBad   bg=NONE ctermfg=s:red[0]    guifg=NONE attr=undercurl guisp=s:red[1]
    Highlight SpellCap   bg=NONE ctermfg=s:aqua[0]   guifg=NONE attr=undercurl guisp=s:aqua[1]
    Highlight SpellLocal bg=NONE ctermfg=s:green[0]  guifg=NONE attr=undercurl guisp=s:green[1]
    Highlight SpellRare  bg=NONE ctermfg=s:orange[0] guifg=NONE attr=undercurl guisp=s:orange[1]
  else
    Highlight SpellBad   bg=NONE fg=s:red                       attr=undercurl guisp=NONE
    Highlight SpellCap   bg=NONE fg=s:aqua                      attr=undercurl guisp=NONE
    Highlight SpellLocal bg=NONE fg=s:green                     attr=undercurl guisp=NONE
    Highlight SpellRare  bg=NONE fg=s:orange                    attr=undercurl guisp=NONE
  endif

  " }}}
" term colors {{{
elseif &t_Co == 8 || $TERM !~# '^linux' || &t_Co == 16
  set t_Co=16
  " term colors from romainl's apprentice
  highlight Normal           ctermbg=NONE       ctermfg=white       cterm=NONE
  set       background=dark

  highlight Comment          ctermbg=NONE       ctermfg=gray        cterm=NONE
  highlight Conceal          ctermbg=NONE       ctermfg=white       cterm=NONE
  highlight Constant         ctermbg=NONE       ctermfg=red         cterm=NONE
  highlight Function         ctermbg=NONE       ctermfg=yellow      cterm=NONE
  highlight Identifier       ctermbg=NONE       ctermfg=darkblue    cterm=NONE
  highlight PreProc          ctermbg=NONE       ctermfg=darkcyan    cterm=NONE
  highlight Special          ctermbg=NONE       ctermfg=darkgreen   cterm=NONE
  highlight Statement        ctermbg=NONE       ctermfg=blue        cterm=NONE
  highlight String           ctermbg=NONE       ctermfg=green       cterm=NONE
  highlight Todo             ctermbg=NONE       ctermfg=NONE        cterm=reverse
  highlight Type             ctermbg=NONE       ctermfg=magenta     cterm=NONE

  highlight Error            ctermbg=NONE       ctermfg=darkred     cterm=reverse
  highlight Ignore           ctermbg=NONE       ctermfg=NONE        cterm=NONE
  highlight Underlined       ctermbg=NONE       ctermfg=NONE        cterm=reverse

  highlight LineNr           ctermbg=black      ctermfg=gray        cterm=NONE
  highlight NonText          ctermbg=NONE       ctermfg=darkgray    cterm=NONE

  highlight Pmenu            ctermbg=darkgray   ctermfg=white       cterm=NONE
  highlight PmenuSbar        ctermbg=gray       ctermfg=NONE        cterm=NONE
  highlight PmenuSel         ctermbg=darkcyan   ctermfg=black       cterm=NONE
  highlight PmenuThumb       ctermbg=darkcyan   ctermfg=NONE        cterm=NONE

  highlight ErrorMsg         ctermbg=darkred    ctermfg=black       cterm=NONE
  highlight ModeMsg          ctermbg=darkgreen  ctermfg=black       cterm=NONE
  highlight MoreMsg          ctermbg=NONE       ctermfg=darkcyan    cterm=NONE
  highlight Question         ctermbg=NONE       ctermfg=green       cterm=NONE
  highlight WarningMsg       ctermbg=NONE       ctermfg=darkred     cterm=NONE

  highlight TabLine          ctermbg=darkgray   ctermfg=darkyellow  cterm=NONE
  highlight TabLineFill      ctermbg=darkgray   ctermfg=black       cterm=NONE
  highlight TabLineSel       ctermbg=darkyellow ctermfg=black       cterm=NONE

  highlight Cursor           ctermbg=NONE       ctermfg=NONE        cterm=NONE
  highlight CursorColumn     ctermbg=darkgray   ctermfg=NONE        cterm=NONE
  highlight CursorLineNr     ctermbg=black      ctermfg=cyan        cterm=NONE
  highlight CursorLine       ctermbg=darkgray   ctermfg=NONE        cterm=NONE

  highlight helpLeadBlank    ctermbg=NONE       ctermfg=NONE        cterm=NONE
  highlight helpNormal       ctermbg=NONE       ctermfg=NONE        cterm=NONE

  highlight StatusLine       ctermbg=darkyellow ctermfg=black       cterm=NONE
  highlight StatusLineNC     ctermbg=darkgray   ctermfg=darkyellow  cterm=NONE

  highlight StatusLineterm   ctermbg=darkyellow ctermfg=black       cterm=NONE
  highlight StatusLinetermNC ctermbg=darkgray   ctermfg=darkyellow  cterm=NONE

  highlight Visual           ctermbg=black      ctermfg=blue        cterm=reverse
  highlight VisualNOS        ctermbg=black      ctermfg=white       cterm=reverse

  highlight FoldColumn       ctermbg=black      ctermfg=darkgray    cterm=NONE
  highlight Folded           ctermbg=black      ctermfg=darkgray    cterm=NONE

  highlight VertSplit        ctermbg=darkgray   ctermfg=darkgray    cterm=NONE
  highlight WildMenu         ctermbg=blue       ctermfg=black       cterm=NONE

  highlight SpecialKey       ctermbg=NONE       ctermfg=darkgray    cterm=NONE
  highlight Title            ctermbg=NONE       ctermfg=white       cterm=NONE

  highlight DiffAdd          ctermbg=black      ctermfg=green       cterm=reverse
  highlight DiffChange       ctermbg=black      ctermfg=magenta     cterm=reverse
  highlight DiffDelete       ctermbg=black      ctermfg=darkred     cterm=reverse
  highlight DiffText         ctermbg=black      ctermfg=red         cterm=reverse

  highlight IncSearch        ctermbg=darkred    ctermfg=black       cterm=NONE
  highlight Search           ctermbg=yellow     ctermfg=black       cterm=NONE

  highlight Directory        ctermbg=NONE       ctermfg=cyan        cterm=NONE
  highlight MatchParen       ctermbg=black      ctermfg=yellow      cterm=NONE

  highlight SpellBad         ctermbg=NONE       ctermfg=darkred     cterm=undercurl
  highlight SpellCap         ctermbg=NONE       ctermfg=darkyellow  cterm=undercurl
  highlight SpellLocal       ctermbg=NONE       ctermfg=darkgreen   cterm=undercurl
  highlight SpellRare        ctermbg=NONE       ctermfg=darkmagenta cterm=undercurl

  highlight ColorColumn      ctermbg=black      ctermfg=NONE        cterm=NONE
  highlight SignColumn       ctermbg=black      ctermfg=darkgray    cterm=NONE

  highlight debugPC          ctermbg=blue
  highlight debugBreakpoint  ctermbg=red
endif
" }}}
" linked groups {{{
hi link Boolean        PreProc
hi link Character      String
hi link Float          Number

hi link Conditional    PreProc
hi link Repeat         PreProc
hi link Label          PreProc
hi link Operator       PreProc
hi link Exception      PreProc
hi link Keyword        PreProc

hi link Include        PreProc
hi link Define         PreProc
hi link Macro          PreProc
hi link PreCondit      PreProc

hi link Debug          Special
hi link Delimiter      Special
hi link Tag            Special

hi link StorageClass   PreProc
hi link Structure      PreProc
hi link Typedef        PreProc

" plugins
hi link pythonDocstring SpecialKey

hi link BufTabLineActive   TabLineSel
hi link BufTabLineCurrent  PmenuSel
hi link BufTabLineHidden   TabLine
hi link BufTabLineFill     TabLineFill

hi link User1 TabLine
hi link User2 IncSearch
hi link User3 StatusLineTermNC
hi link User4 PmenuSel
hi link User5 IncSearch
hi link User6 WildMenu
hi link User7 DiffAdd
hi link User8 StatusLineTerm
hi link User9 StatusLineTerm

" }}}
" terminal colors {{{
if has('nvim')
  let g:terminal_color_0 = s:dark0[1]
  let g:terminal_color_8 = s:light3[1]

  let g:terminal_color_1 = s:red[1]
  let g:terminal_color_9 = s:red[1]

  let g:terminal_color_2 = s:lgreen[1]
  let g:terminal_color_10 = s:green[1]

  let g:terminal_color_3 = s:orange[1]
  let g:terminal_color_11 = s:yellow[1]

  let g:terminal_color_4 = s:lblue[1]
  let g:terminal_color_12 = s:blue[1]

  let g:terminal_color_5 = s:violet[1]
  let g:terminal_color_13 = s:violet[1]

  let g:terminal_color_6 = s:laqua[1]
  let g:terminal_color_14 = s:aqua[1]

  let g:terminal_color_7 = s:light2[1]
  let g:terminal_color_15 = s:light0[1]
endif
" }}}
" Cleanup
delcommand Highlight

" vim: set ts=2 sw=2 et :
