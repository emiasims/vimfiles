setlocal spell
setlocal expandtab
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
setlocal formatlistpat+=^\\s*[-–+o*•]\\s\\+      " Bullet points
setlocal comments=b:*,b:-,b:1.,b:a.
setlocal wrap
setlocal conceallevel=0
setlocal breakindent
setlocal breakindentopt=min:50,shift:2
setlocal commentstring=<!--%s-->

let b:ncm2_look_enabled = 1
let b:autopairs_skip = ["'"]
let b:post_pumaccept = ' '

imap <buffer> <c-x><c-i> <plug>(citebib-complete)
nnoremap <buffer><silent> gO :lvimgrep /^#/ %<CR>:lopen<CR>
nnoremap <buffer> <leader>J vipJgqip

nnoremap <buffer><silent> <F11> :set ft=markdown<CR>
nnoremap <buffer><silent> <F12> :packadd vim-pandoc-syntax<CR>:setlocal filetype=pandoc<CR>:so $CFGDIR/after/ftplugin/markdown.vim<CR>

function! g:md_foldheaders(lnum) abort
  let l:level = matchend(getline(a:lnum), '^#*')
  let l:nextlevel =  matchend(getline(a:lnum + 1), '^#*')
  if l:level > 0
    return '>' . l:level
  elseif l:nextlevel > 0
    return '<' . l:nextlevel
  endif
  return '='
endfunction

setlocal foldmethod=expr
setlocal foldexpr=g:md_foldheaders(v:lnum)

" vim: set ts=2 sw=2 tw=99 et :
