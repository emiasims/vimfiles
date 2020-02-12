if !has('nvim')
  finish
endif

nnoremap <silent> <Plug>ReplSendline :<C-u>call repl#send()<CR>j
      \:call repeat#set("\<Plug>ReplSendline")<CR>

nmap gxl <Plug>ReplSendline
nnoremap <silent> gx<CR> :<C-u>call repl#send("\<lt>CR>")<CR>
nnoremap <silent> gx     :<C-u>set opfunc=repl#opfunc<CR>g@
xnoremap <silent> gx     :call repl#send()<CR>

nnoremap <expr> gr repl#goto_expr()

command! TermRepl terminal | let [repl#termid, repl#bufid] = [b:terminal_job_id, bufnr()]
command! SetRepl let [repl#termid, repl#bufid] = [b:terminal_job_id, bufnr()]

let repl#termid = -1
let repl#bufid = -1
