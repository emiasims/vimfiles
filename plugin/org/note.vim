augroup org_notebox " {{{2
  autocmd!
  autocmd User OrgRefilePre if g:org#refile#destination.filename =~# 'notebox.org$' | call org#note#fromhl(g:org#refile#source) | endif
augroup END


