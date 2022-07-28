setlocal spell
setlocal softtabstop=1  " if I have two spaces in a sentence, delete only one.
setlocal autoindent
setlocal textwidth=0
setlocal formatoptions=12crqno
setlocal comments=n:>
setlocal formatlistpat=^\\s*                     " Optional leading whitespace
setlocal formatlistpat+=[                        " Start character class
setlocal formatlistpat+=\\[({]\\?                " |  Optionally match opening punctuation
setlocal formatlistpat+=\\(                      " |  Start group
setlocal formatlistpat+=[0-9]\\+                 " |  |  Numbers
setlocal formatlistpat+=\\\|                     " |  |  or
setlocal formatlistpat+=[a-zA-Z]\\+              " |  |  Letters
setlocal formatlistpat+=\\)                      " |  End group
setlocal formatlistpat+=[\\]:.)}                 " |  Closing punctuation
setlocal formatlistpat+=]                        " End character class
setlocal formatlistpat+=\\s\\+                   " One or more spaces
setlocal formatlistpat+=\\\|                     " or
setlocal formatlistpat+=^\\s*[-+*]\\s\\+      " Bullet points
setlocal comments=b:*,b:-
setlocal wrap
setlocal conceallevel=0
setlocal breakindent
setlocal breakindentopt=min:50,shift:2
setlocal commentstring=<!--%s-->

let b:ncm2_look_enabled = 1
let b:autopairs_skip = ["'"]
let b:post_pumaccept = ' '

nnoremap <buffer><silent> gO :lvimgrep /^#/ %<CR>:lopen<CR>
nnoremap <buffer> <leader>J vipJgqip
nnoremap <buffer> <leader>K vipJ:let store_reg = @/ \| .s/[.!?]\zs\s\+\ze\u/\r/geI \| let @/ = store_reg \| unl store_reg<CR>

nnoremap <buffer><silent> <F11> :set ft=markdown<CR>
nnoremap <buffer><silent> <F12> :packadd vim-pandoc-syntax<CR>:setlocal filetype=pandoc<CR>:so $CFGDIR/after/ftplugin/markdown.vim<CR>

packadd thesaurus_query.vim
inoremap <buffer><silent> <F9> <Esc>viw"ty:ThesaurusQueryReplace <C-r>t<CR>
nnoremap <buffer><silent> <F9>      viw"ty:ThesaurusQueryReplace <C-r>t<CR>
setlocal completefunc=thesaurus_query#auto_complete_integrate

nnoremap <buffer> <localleader>w :%s/\s\+$// \| normal! ``<CR>
