if !has('nvim')
  finish
endif

nnoremap <silent> <Plug>ReplSendline :<C-u>call repl#send()<CR>j
      \:call repeat#set("\<Plug>ReplSendline")<CR>

nmap gxl <Plug>ReplSendline
nnoremap <silent> gx<CR> :<C-u>call repl#send("\<lt>CR>")<CR>
nnoremap <silent> gx     :<C-u>set opfunc=repl#opfunc<CR>g@
xnoremap <silent> gx     :call repl#send()<CR>

nnoremap <expr> gr empty(repl#winnr()) ? '' : (repl#winnr() . '<C-w>w')

let g:repl#join = "\<Cr>\<C-u>"

command! -nargs=0 SetRepl let [repl#termid, repl#bufid] = [b:terminal_job_id, bufnr()]
command! -nargs=0 TermRepl execute 'terminal' | SetRepl
command! -nargs=0 ClearRepl let [repl#bufid, repl#termid] = [-1, -1]
ClearRepl

augroup repl
  autocmd!
  autocmd TermOpen term://* if repl#termid == -1 | execute 'SetRepl' | endif
  autocmd TermClose term://* if get(b:, 'terminal_job_id', -1) == g:repl#termid | execute 'ClearRepl' | endif
augroup END
