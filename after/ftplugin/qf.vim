nnoremap <silent><buffer> q :q<CR>
setlocal nolist
setlocal tabstop=4
nnoremap <buffer> <Cr> <Cr>
nnoremap <silent><buffer> dd :call qf#delitem()\|silent! call repeat#set("dd")<Cr>
xnoremap <silent><buffer><nowait> d :call qf#delitem()\|silent! call repeat#set("d")<Cr>
nnoremap <silent><buffer> u :<C-u>call qf#undo()<Cr>
nnoremap <silent><buffer> <C-r> :<C-u>call qf#redo()<Cr>
