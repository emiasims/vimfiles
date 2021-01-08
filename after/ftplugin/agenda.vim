let g:agenda#date = 'tomorrow'
nnoremap <buffer> \s :call myorg#agenda_plan({'SCHEDULED': g:agenda#date})<Cr>
nnoremap <buffer> \t :call myorg#agenda_plan({'TIMESTAMP': g:agenda#date})<Cr>
nnoremap <buffer> \e :call myorg#agenda_plan({'DEADLINE': g:agenda#date})<Cr>
nnoremap <buffer> \r :call myorg#agenda_plan('repeat')<Cr>
nnoremap <buffer> \d :call myorg#agenda_done()<Cr>
nnoremap <buffer> ]k :call myorg#agenda_kwcycle(v:count1)<Cr>
nnoremap <buffer> [k :call myorg#agenda_kwcycle(-v:count1)<Cr>
nnoremap <silent> <buffer> q :q\|unlet! g:last_agenda\|let g:agenda#date = 'tomorrow'<Cr>

command! -nargs=+ -buffer SetDate let g:agenda#date = <q-args>
 
" command!
