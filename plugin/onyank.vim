
" let g:onyank#match = '^\s*\c\((vimcmd\|vimyank\|vimdo\|onyank)\)'
let g:onyank#match = '^\s*\c\v\((vimcmd|vimyank|vimdo|onyank)\)'

" from commentary.vim: https://github.com/tpope/vim-commentary/tree/627308e30639be3e2d5402808ce18690557e8292
" See :h license for the license
function! s:surroundings() abort
  return split(get(b:, 'commentary_format', substitute(substitute(substitute(
        \ &commentstring, '^$', '%s', ''), '\S\zs%s',' %s', '') ,'%s\ze\S', '%s ', '')), '%s', 1)
endfunction

function! s:strip_white_space(l,r,line) abort
  let [l, r] = [a:l, a:r]
  if l[-1:] ==# ' ' && stridx(a:line,l) == -1 && stridx(a:line,l[0:-2]) == 0
    let l = l[:-2]
  endif
  if r[0] ==# ' ' && a:line[-strlen(r):] != r && a:line[1-strlen(r):] == r[1:]
    let r = r[1:]
  endif
  return [l, r]
endfunction

" modified a bit, but still mostly from commentary. see s:go in the plugin
function! s:get_text(text) abort
  let [l, r] = s:surroundings()
  let uncomment = 2
  let force_uncomment = 1
  for textline in a:text
    let line = matchstr(textline,'\S.*\s\@<!')
    let [l, r] = s:strip_white_space(l,r,line)
    if len(line) && (stridx(line,l) || line[strlen(line)-strlen(r) : -1] != r)
      let uncomment = 0
    endif
  endfor

  let lines = []
  for line in a:text
    if strlen(r) > 2 && l.r !~# '\\'
      let line = substitute(line,
            \'\M' . substitute(l, '\ze\S\s*$', '\\zs\\d\\*\\ze', '') . '\|' . substitute(r, '\S\zs', '\\zs\\d\\*\\ze', ''),
            \'\=substitute(submatch(0)+1-uncomment,"^0$\\|^-\\d*$","","")','g')
    endif
    if line =~ '^\s*' . l  " here, was "if force_uncomment", which we want.
      let line = substitute(line,'\S.*\s\@<!','\=submatch(0)[strlen(l):-strlen(r)-1]','')
    endif
    call add(lines, line)
  endfor
  return lines
endfunction

function! s:yank_matches() abort " {{{2
  return s:get_text([ v:event.regcontents[0] ])[0] =~ g:onyank#match
endfunction

function! s:process_register() abort " {{{2
  " TODO Do not process deletions
  " If there are multiple (onyank)s, process them sequentially
  let cmd = map(s:get_text(v:event.regcontents), {i, v -> substitute(v, g:onyank#match, '', '')})
  try
    execute join(cmd, "\n")
  catch /^Vim\%((\a\+)\)\=:E523/
    " Occurs due to :h textlock from TextYankPost.
    call timer_start(0, {_ -> execute(join(cmd, "\n"))})
  endtry
endfunction

augroup onyank
  autocmd!
  autocmd TextYankPost * if s:yank_matches() | call s:process_register() | endif
augroup END

