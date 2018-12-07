if !has('nvim')
  finish
endif

nnoremap <silent> <Plug>ReplSendline :<C-u>call repl#send()<CR>j
      \:call repeat#set("\<Plug>ReplSendline")<CR>

nmap gxl <Plug>ReplSendline
nnoremap <silent> gx<CR> :<C-u>call repl#send("\<lt>CR>")<CR>
nnoremap <silent> gx     :<C-u>set opfunc=repl#opfunc<CR>g@
xnoremap <silent> gx     :call repl#send()<CR>

let g:repl_termid = -1
augroup vimrc_repl
  autocmd!
  autocmd BufLeave * let g:repl_termid = get(b:, 'terminal_job_id', g:repl_termid)
augroup END

" vim: set ts=2 sw=2 tw=99 et :
