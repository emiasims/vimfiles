augroup org_notebox " {{{2
  autocmd!
  autocmd User OrgRefilePre if g:org#refile#destination.filename =~# 'notebox.org$' | call org#note#fromhl(g:org#refile#source) | endif
  " outline creates a new tab, which is not allowed in completion
  " autocmd BufWritePost notebox.org call org#outline#file('notebox.org')
  autocmd BufReadPost,BufWritePost notebox.org call org#outline#file('notebox.org')
  autocmd BufReadPost notebox.org inoremap <buffer> <expr> <c-x><c-i> org#note#fzfcompl()
  " autocmd InsertLeave *.org call org#note#make_inserted_links()
augroup END


