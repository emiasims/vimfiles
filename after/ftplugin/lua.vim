" setlocal formatprg=stylua\ -
setlocal formatexpr=v:lua.vim.lsp.formatexpr()
setlocal comments=:---,:--

nnoremap <silent> <expr> <buffer> K ':help ' . expand('<cword>') . ((expand('<cWORD>') =~# expand('<cword>') . '(') ? "(\<Cr>" : "\<Cr>")
setlocal tagfunc=v:lua.vim.lsp.tagfunc

if expand('%') =~? '_spec.lua$'
  nmap <buffer> \t <Plug>PlenaryTestFile
endif

nnoremap <buffer> <Bs> <cmd>call testing#prompt()<Cr>

for i in range(97, 122)  " a-z, make <C-v><C-a> insert <C-a>.
  execute 'inoremap <buffer> <C-v><C-' . nr2char(i) . '> <lt>C-' . nr2char(i) . '>'
endfor
inoremap <buffer> <C-v><Esc> <lt>Esc>
inoremap <buffer> <C-v><Tab> <lt>Tab>
inoremap <buffer> <C-v><Cr> <lt>Cr>

let b:refactor_prefix = 'local'
