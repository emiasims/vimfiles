" 'evolution.vim' -- Vim color scheme.
" Author:       Matt Simmons (mtszyk@gmail.com)
" Last Change:  2018-06-21

hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'evolution'

highlight Normal           ctermfg=187  guifg=#d5c4a1 ctermbg=234  guibg=#1d2021 cterm=NONE      gui=NONE
" highlight NormalNC         ctermfg=187  guifg=#bdae93 ctermbg=234  guibg=#1d2021 cterm=NONE    gui=NONE
set       background=dark

highlight LineNr           ctermfg=239  guifg=#504945 ctermbg=234  guibg=#1d2021 cterm=NONE      gui=NONE
highlight SignColumn       ctermfg=235  guifg=#282828 ctermbg=234  guibg=#1d2021 cterm=NONE      gui=NONE
highlight FoldColumn       ctermfg=239  guifg=#504945 ctermbg=234  guibg=#1d2021 cterm=NONE      gui=NONE
highlight MatchParen       ctermfg=73   guifg=#72b7b5 ctermbg=239  guibg=#504945 cterm=NONE      gui=NONE

highlight Statement        ctermfg=108  guifg=#83a598 ctermbg=NONE guibg=NONE    cterm=bold      gui=bold
highlight PreProc          ctermfg=108  guifg=#83a598 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Function         ctermfg=73   guifg=#6fa3a6 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight String           ctermfg=65   guifg=#679a69 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
" highlight Number           ctermfg=139  guifg=#c099c9 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Number           ctermfg=139  guifg=#b48ead ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE

highlight Folded           ctermfg=102  guifg=#948774 ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight Comment          ctermfg=102  guifg=#948774 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE
" highlight Comment          ctermfg=102  guifg=#948774 ctermbg=NONE guibg=NONE    cterm=italic    gui=italic
highlight Identifier       ctermfg=65   guifg=#91ba93 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Type             ctermfg=108  guifg=#83a598 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Special          ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Constant         ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Error            ctermfg=167  guifg=#D84A44 ctermbg=NONE guibg=NONE    cterm=bold      gui=bold
highlight Todo             ctermfg=172  guifg=#d79921 ctermbg=NONE guibg=NONE    cterm=bold      gui=bold
highlight NonText          ctermfg=237  guifg=#3c3836 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE

highlight WildMenu         ctermfg=73   guifg=#72b7b5 ctermbg=239  guibg=#504945 cterm=NONE      gui=NONE
highlight PMenu            ctermfg=187  guifg=#d5c4a1 ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight PmenuSbar        ctermfg=187  guifg=#d5c4a1 ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight PMenuSel         ctermfg=73   guifg=#72b7b5 ctermbg=237  guibg=#3c3836 cterm=NONE      gui=NONE
highlight PmenuThumb       ctermfg=138  guifg=#a89984 ctermbg=237  guibg=#3c3836 cterm=NONE      gui=NONE

highlight ErrorMsg         ctermfg=187  guifg=#d5c4a1 ctermbg=167  guibg=#D84A44 cterm=NONE      gui=NONE
highlight ModeMsg          ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight MoreMsg          ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Question         ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight WarningMsg       ctermfg=167  guifg=#D84A44 ctermbg=234  guibg=#1d2021 cterm=NONE      gui=NONE
highlight TabLine          ctermfg=102  guifg=#948774 ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight TabLineFill      ctermfg=102  guifg=#948774 ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight TabLineSel       ctermfg=102  guifg=#948774 ctermbg=239  guibg=#504945 cterm=NONE      gui=NONE
highlight Cursor           ctermfg=234  guifg=#1d2021 ctermbg=187  guibg=#d5c4a1 cterm=NONE      gui=NONE
highlight CursorColumn     ctermfg=NONE guifg=NONE    ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight CursorLineNr     ctermfg=73   guifg=#72b7b5 ctermbg=234  guibg=#1d2021 cterm=NONE      gui=NONE
highlight CursorLine       ctermfg=NONE guifg=NONE    ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight ColorColumn      ctermfg=NONE guifg=NONE    ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight StatusLine       ctermfg=144  guifg=#bdae93 ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight StatusLineNC     ctermfg=102  guifg=#948774 ctermbg=237  guibg=#3c3836 cterm=NONE      gui=NONE

highlight StatusLineTerm   ctermfg=73   guifg=#72b7b5 ctermbg=237  guibg=#3c3836 cterm=NONE      gui=NONE
highlight StatusLineTermNC ctermfg=187  guifg=#d5c4a1 ctermbg=235  guibg=#282828 cterm=NONE      gui=NONE
highlight Visual           ctermfg=NONE guifg=NONE    ctermbg=237  guibg=#3c3836 cterm=NONE      gui=NONE
highlight VisualNOS        ctermfg=NONE guifg=NONE    ctermbg=237  guibg=#3c3836 cterm=NONE      gui=NONE
highlight VertSplit        ctermfg=237  guifg=#3c3836 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight SpecialKey       ctermfg=102  guifg=#948774 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight Title            ctermfg=187  guifg=#d5c4a1 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight DiffAdd          ctermfg=NONE guifg=NONE    ctermbg=65   guibg=#29342d cterm=NONE      gui=NONE
highlight DiffChange       ctermfg=NONE guifg=NONE    ctermbg=172  guibg=#3c3421 cterm=NONE      gui=NONE
highlight DiffDelete       ctermfg=NONE guifg=NONE    ctermbg=167  guibg=#4c2b2a cterm=NONE      gui=NONE
highlight DiffText         ctermfg=NONE guifg=NONE    ctermbg=108  guibg=#2b393a cterm=NONE      gui=NONE
highlight IncSearch        ctermfg=235  guifg=#282828 ctermbg=173  guibg=#c7743e cterm=NONE      gui=NONE
highlight Search           ctermfg=235  guifg=#282828 ctermbg=173  guibg=#c7743e cterm=NONE      gui=NONE
highlight QuickFixLine     ctermfg=NONE guifg=NONE    ctermbg=173  guibg=#2c2824 cterm=NONE      gui=NONE
highlight Directory        ctermfg=73   guifg=#72b7b5 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
highlight SpecialChar      ctermfg=172  guifg=#d79921 ctermbg=NONE guibg=NONE    cterm=NONE      gui=NONE
" highlight SpecialComment   ctermfg=73   guifg=#72b7b5 ctermbg=NONE guibg=NONE    cterm=italic    gui=italic
highlight SpecialComment   ctermfg=73   guifg=#72b7b5 ctermbg=NONE guibg=NONE    cterm=NONE    gui=NONE

highlight SpellBad         ctermbg=NONE guibg=NONE    ctermfg=167  guifg=#D84A44 cterm=undercurl gui=undercurl guisp=NONE
highlight SpellCap         ctermbg=NONE guibg=NONE    ctermfg=73   guifg=#72b7b5 cterm=undercurl gui=undercurl guisp=NONE
highlight SpellLocal       ctermbg=NONE guibg=NONE    ctermfg=65   guifg=#679a69 cterm=undercurl gui=undercurl guisp=NONE
highlight SpellRare        ctermbg=NONE guibg=NONE    ctermfg=173  guifg=#c7743e cterm=undercurl gui=undercurl guisp=NONE

" terminal colors {{{
if has('nvim')
  let g:terminal_color_0  = '#1d2021'
  let g:terminal_color_1  = '#D84A44'
  let g:terminal_color_2  = '#91ba93'
  let g:terminal_color_3  = '#d65d0e'
  let g:terminal_color_4  = '#83a598'
  let g:terminal_color_5  = '#b48ead'
  let g:terminal_color_6  = '#84d4d2'
  let g:terminal_color_7  = '#a89984'
  let g:terminal_color_8  = '#948774'
  let g:terminal_color_9  = '#D84A44'
  let g:terminal_color_10 = '#679a69'
  let g:terminal_color_11 = '#d79921'
  let g:terminal_color_12 = '#6fa3a6'
  let g:terminal_color_13 = '#b48ead'
  let g:terminal_color_14 = '#72b7b5'
  let g:terminal_color_15 = '#d5c4a1'
else
  let g:terminal_ansi_colors = [
              \ '#1d2021',
              \ '#D84A44',
              \ '#91ba93',
              \ '#d65d0e',
              \ '#83a598',
              \ '#b48ead',
              \ '#84d4d2',
              \ '#a89984',
              \ '#948774',
              \ '#D84A44',
              \ '#679a69',
              \ '#d79921',
              \ '#6fa3a6',
              \ '#b48ead',
              \ '#72b7b5',
              \ '#d5c4a1'
              \ ]
endif
" }}}
" linked groups {{{

hi! link Boolean        PreProc
hi! link Character      String
hi! link Float          Number
hi! link Conditional    PreProc
hi! link Define         PreProc
hi! link Exception      PreProc
hi! link Include        PreProc
hi! link Keyword        PreProc
hi! link Label          PreProc
hi! link Macro          PreProc
hi! link Operator       PreProc
hi! link PreCondit      PreProc
hi! link Repeat         PreProc
hi! link StorageClass   PreProc
hi! link Structure      PreProc
hi! link Typedef        PreProc
hi! link Debug          Special
hi! link Delimiter      Special
hi! link Tag            Special
hi! link Terminal       Normal
hi! link Conceal        Whitespace

highlight Sneak               ctermfg=108 guifg=#d79921 ctermbg=235 guibg=#3c3836 cterm=bold gui=bold
highlight SneakLabel          ctermfg=108 guifg=#d79921 ctermbg=235 guibg=#3c3836 cterm=bold gui=bold

highlight StatusLine          ctermfg=144 guifg=#bdae93 ctermbg=235 guibg=#282828 cterm=NONE gui=NONE
highlight StatusLineNC        ctermfg=102 guifg=#948774 ctermbg=237 guibg=#3c3836 cterm=NONE gui=NONE

highlight StatusLineTerm      ctermfg=73  guifg=#72b7b5 ctermbg=237 guibg=#3c3836 cterm=NONE gui=NONE
highlight StatusLineTermNC    ctermfg=187 guifg=#d5c4a1 ctermbg=235 guibg=#282828 cterm=NONE gui=NONE

highlight stlModified         ctermfg=167 guifg=#d84a44 ctermbg=235 guibg=#282828 cterm=bold gui=bold
highlight stlTypeInfo         ctermfg=73  guifg=#6fa3a6 ctermbg=235 guibg=#282828 cterm=NONE gui=NONE
highlight stlDirInfo          ctermfg=116 guifg=#84d4d2 ctermbg=237 guibg=#3c3836 cterm=NONE gui=NONE
highlight stlErrorInfo        ctermfg=167 guifg=#d84a44 ctermbg=235 guibg=#282828 cterm=NONE gui=NONE

highlight stlNormalMode       ctermfg=172 guifg=#d79921 ctermbg=239 guibg=#504945 cterm=bold gui=bold
highlight stlInsertMode       ctermfg=234 guifg=#1d2021 ctermbg=65  guibg=#679a69 cterm=bold gui=bold
highlight stlVisualMode       ctermfg=234 guifg=#1d2021 ctermbg=173 guibg=#c7743e cterm=NONE gui=NONE
highlight stlReplaceMode      ctermfg=234 guifg=#1d2021 ctermbg=73  guibg=#6fa3a6 cterm=NONE gui=NONE
highlight stlSelectMode       ctermfg=234 guifg=#1d2021 ctermbg=73  guibg=#6fa3a6 cterm=NONE gui=NONE
highlight stlTerminalMode     ctermfg=139 guifg=#b48ead ctermbg=239 guibg=#504945 cterm=NONE gui=NONE

" }}}
