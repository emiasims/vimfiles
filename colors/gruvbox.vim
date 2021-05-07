hi clear
syntax reset
set t_Co=256
let g:colors_name='gruvbox'
highlight! link orgListTag Comment
highlight orgNodeProperty guifg=#B7808F guibg=NONE guisp=NONE gui=NONE
highlight! link orgNodeMultiProperty orgNodeProperty
highlight! link orgPropertyDrawerEnds Comment
highlight! link orgPropertyName PreProc
highlight! link orgURI Comment
highlight! link orgLinkEnds Conceal
highlight! link orgLinkDescription Tag
highlight! link orgSetting Error
highlight! link orgSettingEnds Comment
highlight! link orgSettingName Todo
highlight! link orgSettingArguments Comment
highlight! link orgComment Comment
highlight orgVerbatim guifg=#EBDBB2 guibg=NONE guisp=NONE gui=NONE
highlight Sneak guifg=#FABD2E guibg=NONE guisp=NONE gui=bold
highlight SneakLabel guifg=#FABD2E guibg=NONE guisp=NONE gui=bold
highlight CursorWord0 guifg=NONE guibg=NONE guisp=NONE gui=underline
highlight CursorWord1 guifg=NONE guibg=NONE guisp=NONE gui=underline
highlight Conceal guifg=#4A4440 guibg=NONE guisp=NONE gui=NONE
highlight ColorColumn guifg=NONE guibg=#363230 guisp=NONE gui=NONE
highlight CursorLine guifg=NONE guibg=#363230 guisp=NONE gui=NONE
highlight! link CursorColumn CursorLine
highlight Directory guifg=#FB4632 guibg=NONE guisp=NONE gui=bold
highlight DiffAdd guifg=#65A838 guibg=NONE guisp=NONE gui=NONE
highlight DiffChange guifg=#8EC07C guibg=NONE guisp=NONE gui=NONE
highlight DiffDelete guifg=#FB4632 guibg=NONE guisp=NONE gui=NONE
highlight DiffText guifg=#FABD2E guibg=NONE guisp=NONE gui=NONE
highlight VertSplit guifg=#2E2E2E guibg=NONE guisp=NONE gui=NONE
highlight Folded guifg=#918273 guibg=#363230 guisp=NONE gui=NONE
highlight FoldColumn guifg=#918273 guibg=#363230 guisp=NONE gui=NONE
highlight SignColumn guifg=NONE guibg=#262626 guisp=NONE gui=NONE
highlight ErrorMsg guifg=#262626 guibg=#FB4632 guisp=NONE gui=bold
highlight Search guifg=NONE guibg=#433F3D guisp=NONE gui=bold
highlight IncSearch guifg=NONE guibg=#655B53 guisp=NONE gui=bold,inverse
highlight LineNr guifg=#7D6F64 guibg=NONE guisp=NONE gui=NONE
highlight CursorLineNr guifg=#FABD2E guibg=NONE guisp=NONE gui=NONE
highlight ModeMsg guifg=#FABD2E guibg=NONE guisp=NONE gui=bold
highlight MoreMsg guifg=#FABD2E guibg=NONE guisp=NONE gui=bold
highlight MatchParen guifg=#FE811B guibg=NONE guisp=NONE gui=bold
highlight NonText guifg=#4A4440 guibg=NONE guisp=NONE gui=NONE
highlight Normal guifg=#EBDBB2 guibg=#262626 guisp=NONE gui=NONE
highlight! link NormalFloat Normal
highlight Pmenu guifg=#EBDBB2 guibg=#363230 guisp=NONE gui=NONE
highlight PmenuSel guifg=#83A598 guibg=#3E3A38 guisp=NONE gui=bold
highlight PmenuSbar guifg=NONE guibg=#4A4440 guisp=NONE gui=NONE
highlight PmenuThumb guifg=NONE guibg=#7D6F64 guisp=NONE gui=NONE
highlight Question guifg=#FE811B guibg=NONE guisp=NONE gui=bold
highlight QuickFixLine guifg=NONE guibg=#363230 guisp=NONE gui=NONE
highlight SpecialKey guifg=#A89985 guibg=NONE guisp=NONE gui=NONE
highlight SpellRare guifg=#D4879C guibg=NONE guisp=NONE gui=underline
highlight SpellBad guifg=#FB4632 guibg=NONE guisp=NONE gui=underline
highlight StatusLine guifg=#EBDBB2 guibg=#2E2E2E guisp=NONE gui=NONE
highlight StatusLineNC guifg=#A89985 guibg=#2E2E2E guisp=NONE gui=NONE
highlight TabLineFill guifg=#7D6F64 guibg=#363230 guisp=NONE gui=NONE
highlight TabLine guifg=#7D6F64 guibg=#363230 guisp=NONE gui=NONE
highlight TabLineSel guifg=#65A838 guibg=#363230 guisp=NONE gui=NONE
highlight TabLineWin guifg=#83A598 guibg=#2E2E2E guisp=NONE gui=bold
highlight TabLineNumber guifg=#65A838 guibg=#2E2E2E guisp=NONE gui=NONE
highlight TabLineSelNumber guifg=#FB4632 guibg=#2E2E2E guisp=NONE gui=bold
highlight stlModified guifg=#FB4632 guibg=#2E2E2E guisp=NONE gui=NONE
highlight stlTypeInfo guifg=#8EC07C guibg=#2E2E2E guisp=NONE gui=NONE
highlight stlDirInfo guifg=#83A598 guibg=#383838 guisp=NONE gui=NONE
highlight stlErrorInfo guifg=#FB4632 guibg=#2E2E2E guisp=NONE gui=NONE
highlight stlNormalMode guifg=#FE811B guibg=#424242 guisp=NONE gui=bold
highlight stlInsertMode guifg=#2E2E2E guibg=#8EC07C guisp=NONE gui=bold
highlight stlVisualMode guifg=#2E2E2E guibg=#FABD2E guisp=NONE gui=bold
highlight stlReplaceMode guifg=#2E2E2E guibg=#83A598 guisp=NONE gui=bold
highlight stlTerminalMode guifg=#D4879C guibg=#424242 guisp=NONE gui=bold
highlight Visual guifg=NONE guibg=#3B3735 guisp=NONE gui=NONE
highlight! link VisualNOS Visual
highlight WarningMsg guifg=#FB4632 guibg=NONE guisp=NONE gui=bold
highlight WildMenu guifg=#83A598 guibg=#4A4440 guisp=NONE gui=bold
highlight Constant guifg=#D4879C guibg=NONE guisp=NONE gui=NONE
highlight String guifg=#65A838 guibg=NONE guisp=NONE gui=NONE
highlight! link Character Constant
highlight! link Number Constant
highlight! link Boolean Constant
highlight! link Float Constant
highlight Identifier guifg=#83A598 guibg=NONE guisp=NONE gui=NONE
highlight Function guifg=#65A838 guibg=NONE guisp=NONE gui=NONE
highlight Statement guifg=#FB4632 guibg=NONE guisp=NONE gui=NONE
highlight! link Conditional Statement
highlight! link Repeat Statement
highlight! link Label Statement
highlight Operator guifg=#EBDBB2 guibg=NONE guisp=NONE gui=NONE
highlight! link Exception Statement
highlight Keyword guifg=#8EC07C guibg=NONE guisp=NONE gui=NONE
highlight PreProc guifg=#8EC07C guibg=NONE guisp=NONE gui=NONE
highlight! link Include PreProc
highlight! link Define PreProc
highlight! link Macro PreProc
highlight! link PreCondit PreProc
highlight Type guifg=#FABD2E guibg=NONE guisp=NONE gui=NONE
highlight StorageClass guifg=#FE811B guibg=NONE guisp=NONE gui=NONE
highlight Structure guifg=#8EC07C guibg=NONE guisp=NONE gui=NONE
highlight Typedef guifg=#FABD2E guibg=NONE guisp=NONE gui=NONE
highlight Special guifg=NONE guibg=NONE guisp=NONE gui=NONE
highlight SpecialChar guifg=#FB4632 guibg=NONE guisp=NONE gui=NONE
highlight Tag guifg=#8EC07C guibg=NONE guisp=NONE gui=bold
highlight Delimiter guifg=#D4C3A0 guibg=NONE guisp=NONE gui=NONE
highlight Comment guifg=#918273 guibg=NONE guisp=NONE gui=NONE
highlight! link SpecialComment Comment
highlight Debug guifg=#FB4632 guibg=NONE guisp=NONE gui=NONE
highlight Underlined guifg=NONE guibg=NONE guisp=NONE gui=underline
highlight Undercurl guifg=NONE guibg=NONE guisp=NONE gui=undercurl
highlight Bold guifg=NONE guibg=NONE guisp=NONE gui=bold
highlight Italic guifg=NONE guibg=NONE guisp=NONE gui=italic
highlight Strikethrough guifg=NONE guibg=NONE guisp=NONE gui=strikethrough
highlight Ignore guifg=NONE guibg=NONE guisp=NONE gui=NONE
highlight Error guifg=#FB4632 guibg=NONE guisp=NONE gui=bold
highlight Todo guifg=#FE811B guibg=NONE guisp=NONE gui=bold
highlight! link Title Identifier
highlight SignifySignAdd guifg=#65A838 guibg=NONE guisp=NONE gui=NONE
highlight SignifySignChange guifg=#8EC07C guibg=NONE guisp=NONE gui=NONE
highlight SignifySignDelete guifg=#FB4632 guibg=NONE guisp=NONE gui=NONE
highlight orgHeadline1 guifg=#83A598 guibg=NONE guisp=NONE gui=bold
highlight orgHeadline2 guifg=#8EC07C guibg=NONE guisp=NONE gui=NONE
highlight orgHeadline3 guifg=#CC8EC8 guibg=NONE guisp=NONE gui=NONE
highlight orgHeadline4 guifg=#65A838 guibg=NONE guisp=NONE gui=NONE
highlight! link orgHeadline5 orgHeadline2
highlight! link orgHeadline6 orgHeadline3
highlight! link orgHeadline7 orgHeadline4
highlight! link orgHeadline8 orgHeadline2
highlight! link orgHeadline9 orgHeadline3
highlight! link orgHeadlineN orgHeadline4
highlight! link orgHeadlineInnerStar Comment
highlight! link orgHeadlineLastStar Constant
highlight! link orgTodo Todo
highlight orgDone guifg=#63887A guibg=NONE guisp=NONE gui=NONE
highlight! link orgHeadlinePriority Error
highlight orgHeadlineTags guifg=#EBDBB2 guibg=NONE guisp=NONE gui=NONE
highlight! link orgPlanDeadline Comment
highlight! link orgPlanScheduled Comment
highlight! link orgPlanClosed Comment
highlight! link orgPlanTime Comment
highlight! link orgPlanning Comment
highlight! link orgDate Comment
highlight! link orgTime Comment
highlight! link orgTimeRepeat Comment
highlight! link orgTimeDelay Comment
highlight! link orgTimestampElements Comment
highlight! link orgListLeader Constant
highlight! link orgListCheck Todo
