if has('nvim') && get(g:, 'loaded_nvim_treesitter', 0)
  setlocal foldmethod=expr
  setlocal foldexpr=v:lua.mia.tslib.fold.queryexpr(v:lnum)
endif

setlocal formatprg=stylua\ -

nnoremap <silent> <expr> <buffer> K ':help ' . expand('<cword>') . ((expand('<cWORD>') =~# expand('<cword>') . '(') ? "(\<Cr>" : "\<Cr>")
setlocal tagfunc=v:lua.vim.lsp.tagfunc

" why is this here?
augroup vimrc_lua
  autocmd!
  if has('nvim')
    autocmd BufWritePre *.py lua vim.lsp.buf.formatting_sync()
  endif
augroup END

let b:refactor_prefix = 'local'
