" 'evolution.vim' -- Vim color scheme.
" Author:       Matt Simmons (mtszyk@gmail.com)
" Last Change:  2018-06-21

hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'evolution'

" True and 256 colors {{{
if ($TERM =~# '256' || &t_Co >= 256) || has('gui_running')

  highlight Normal           ctermfg=187  guifg=#d5c4a1 ctermbg=234  guibg=#1d2021 cterm=NONE      gui=NONE
  set background=dark

  highlight LineNr           ctermfg=239  guifg=#504945 ctermbg=234  guibg=#1d2021 cterm=NONE    gui=NONE
  highlight SignColumn       ctermfg=235  guifg=#282828 ctermbg=234  guibg=#1d2021 cterm=NONE    gui=NONE
  highlight FoldColumn       ctermfg=239  guifg=#504945 ctermbg=234  guibg=#1d2021 cterm=NONE    gui=NONE
  highlight MatchParen       ctermfg=73   guifg=#72b7b5 ctermbg=239  guibg=#504945 cterm=NONE    gui=NONE

  highlight Statement        ctermfg=108  guifg=#83a598 ctermbg=NONE guibg=NONE    cterm=bold    gui=bold
  highlight PreProc          ctermfg=108  guifg=#83a598 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Function         ctermfg=73   guifg=#6fa3a6 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight String           ctermfg=65   guifg=#679a69 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Number           ctermfg=139  guifg=#b48ead ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE

  highlight Folded           ctermfg=102  guifg=#948774 ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight Comment          ctermfg=102  guifg=#948774 ctermbg=NONE guibg=NONE    cterm=italic  gui=italic
  highlight Identifier       ctermfg=65   guifg=#91ba93 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Type             ctermfg=108  guifg=#83a598 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Special          ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Constant         ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Error            ctermfg=167  guifg=#D84A44 ctermbg=NONE guibg=NONE    cterm=bold    gui=bold
  highlight Todo             ctermfg=172  guifg=#d79921 ctermbg=NONE guibg=NONE    cterm=bold    gui=bold
  highlight NonText          ctermfg=237  guifg=#3c3836 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE

  highlight WildMenu         ctermfg=73   guifg=#72b7b5 ctermbg=239  guibg=#504945 cterm=NONE    gui=NONE
  highlight PMenu            ctermfg=187  guifg=#d5c4a1 ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight PmenuSbar        ctermfg=187  guifg=#d5c4a1 ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight PMenuSel         ctermfg=73   guifg=#72b7b5 ctermbg=237  guibg=#3c3836 cterm=NONE    gui=NONE
  highlight PmenuThumb       ctermfg=138  guifg=#a89984 ctermbg=237  guibg=#3c3836 cterm=NONE    gui=NONE

  highlight ErrorMsg         ctermfg=187  guifg=#d5c4a1 ctermbg=167  guibg=#D84A44 cterm=NONE    gui=NONE
  highlight ModeMsg          ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight MoreMsg          ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Question         ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight WarningMsg       ctermfg=167  guifg=#D84A44 ctermbg=234  guibg=#1d2021 cterm=NONE    gui=NONE
  highlight TabLine          ctermfg=102  guifg=#948774 ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight TabLineFill      ctermfg=102  guifg=#948774 ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight TabLineSel       ctermfg=102  guifg=#948774 ctermbg=239  guibg=#504945 cterm=NONE    gui=NONE
  highlight Cursor           ctermfg=234  guifg=#1d2021 ctermbg=187  guibg=#d5c4a1 cterm=NONE    gui=NONE
  highlight CursorColumn     ctermfg=NONE guifg=NONE    ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight CursorLineNr     ctermfg=73   guifg=#72b7b5 ctermbg=234  guibg=#1d2021 cterm=NONE    gui=NONE
  highlight CursorLine       ctermfg=NONE guifg=NONE    ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight ColorColumn      ctermfg=NONE guifg=NONE    ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight StatusLine       ctermfg=144  guifg=#bdae93 ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight StatusLineNC     ctermfg=102  guifg=#948774 ctermbg=237  guibg=#3c3836 cterm=NONE    gui=NONE

  highlight StatusLineTerm   ctermfg=73   guifg=#72b7b5 ctermbg=237  guibg=#3c3836 cterm=NONE    gui=NONE
  highlight StatusLineTermNC ctermfg=187  guifg=#d5c4a1 ctermbg=235  guibg=#282828 cterm=NONE    gui=NONE
  highlight Visual           ctermfg=NONE guifg=NONE    ctermbg=237  guibg=#3c3836 cterm=NONE    gui=NONE
  highlight VisualNOS        ctermfg=NONE guifg=NONE    ctermbg=237  guibg=#3c3836 cterm=NONE    gui=NONE
  highlight VertSplit        ctermfg=237  guifg=#3c3836 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight SpecialKey       ctermfg=102  guifg=#948774 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight Title            ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight DiffAdd          ctermfg=65   guifg=#679a69 ctermbg=235  guibg=#282828 cterm=reverse gui=reverse
  highlight DiffChange       ctermfg=172  guifg=#d79921 ctermbg=235  guibg=#282828 cterm=reverse gui=reverse
  highlight DiffDelete       ctermfg=167  guifg=#D84A44 ctermbg=235  guibg=#282828 cterm=reverse gui=reverse
  highlight DiffText         ctermfg=108  guifg=#83a598 ctermbg=235  guibg=#282828 cterm=reverse gui=reverse
  highlight IncSearch        ctermfg=235  guifg=#282828 ctermbg=173  guibg=#c7743e cterm=NONE    gui=NONE
  highlight Search           ctermfg=235  guifg=#282828 ctermbg=173  guibg=#c7743e cterm=NONE    gui=NONE
  highlight Directory        ctermfg=73   guifg=#72b7b5 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight SpecialChar      ctermfg=172  guifg=#d79921 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
  highlight SpecialComment   ctermfg=73   guifg=#72b7b5 ctermbg=NONE guibg=NONE    cterm=italic  gui=italic

  highlight stlTypeInfo      ctermfg=73   guifg=#6fa3a6 ctermbg=234  guibg=#1d2021 cterm=NONE    gui=NONE
  highlight stlErrorInfo     ctermfg=234  guifg=#1d2021 ctermbg=173  guibg=#c7743e cterm=bold    gui=bold
  highlight stlDirInfo       ctermfg=116  guifg=#84d4d2 ctermbg=237  guibg=#3c3836 cterm=NONE    gui=NONE

  highlight stlNormal        ctermfg=172  guifg=#d79921 ctermbg=239  guibg=#504945 cterm=bold    gui=bold
  highlight stlInsert        ctermfg=234  guifg=#1d2021 ctermbg=65   guibg=#679a69 cterm=bold    gui=bold
  highlight stlVisual        ctermfg=234  guifg=#1d2021 ctermbg=173  guibg=#c7743e cterm=NONE    gui=NONE
  highlight stlReplace       ctermfg=234  guifg=#1d2021 ctermbg=73   guibg=#6fa3a6 cterm=NONE    gui=NONE
  highlight stlSelect        ctermfg=234  guifg=#1d2021 ctermbg=73   guibg=#6fa3a6 cterm=NONE    gui=NONE
  highlight stlTerminal      ctermfg=139  guifg=#b48ead ctermbg=239  guibg=#504945 cterm=NONE    gui=NONE

  highlight debugPC          ctermbg=73   guibg=#6fa3a6
  highlight debugBreakpoint  ctermbg=167  guibg=#D84A44

  if has('gui_running')
    highlight SpellBad   ctermbg=NONE guibg=NONE ctermfg=167 guifg=NONE    cterm=undercurl gui=undercurl guisp=#D84A44
    highlight SpellCap   ctermbg=NONE guibg=NONE ctermfg=73  guifg=NONE    cterm=undercurl gui=undercurl guisp=#72b7b5
    highlight SpellLocal ctermbg=NONE guibg=NONE ctermfg=65  guifg=NONE    cterm=undercurl gui=undercurl guisp=#679a69
    highlight SpellRare  ctermbg=NONE guibg=NONE ctermfg=173 guifg=NONE    cterm=undercurl gui=undercurl guisp=#c7743e
  else
    highlight SpellBad   ctermbg=NONE guibg=NONE ctermfg=167 guifg=#D84A44 cterm=undercurl gui=undercurl guisp=NONE
    highlight SpellCap   ctermbg=NONE guibg=NONE ctermfg=73  guifg=#72b7b5 cterm=undercurl gui=undercurl guisp=NONE
    highlight SpellLocal ctermbg=NONE guibg=NONE ctermfg=65  guifg=#679a69 cterm=undercurl gui=undercurl guisp=NONE
    highlight SpellRare  ctermbg=NONE guibg=NONE ctermfg=173 guifg=#c7743e cterm=undercurl gui=undercurl guisp=NONE
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
  let g:terminal_color_0 = '#1d2021'
  let g:terminal_color_8 = '#948774'

  let g:terminal_color_1 = '#D84A44'
  let g:terminal_color_9 = '#D84A44'

  let g:terminal_color_2 = '#91ba93'
  let g:terminal_color_10 = '#679a69'

  let g:terminal_color_3 = '#d65d0e'
  let g:terminal_color_11 = '#d79921'

  let g:terminal_color_4 = '#83a598'
  let g:terminal_color_12 = '#6fa3a6'

  let g:terminal_color_5 = '#b48ead'
  let g:terminal_color_13 = '#b48ead'

  let g:terminal_color_6 = '#84d4d2'
  let g:terminal_color_14 = '#72b7b5'

  let g:terminal_color_7 = '#a89984'
  let g:terminal_color_15 = '#d5c4a1'
endif
" }}}

" vim: set ts=2 sw=2 et :
