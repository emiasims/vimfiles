if has('nvim') && get(g:, 'loaded_nvim_treesitter', 0)
  setlocal foldmethod=expr
  setlocal foldexpr=v:lua.mia.tslib.fold.queryexpr(v:lnum)
endif

setlocal formatprg=stylua\ -

nnoremap <silent> <expr> <buffer> K ':help ' . expand('<cword>') . ((expand('<cWORD>') =~# expand('<cword>') . '(') ? "(\<Cr>" : "\<Cr>")
