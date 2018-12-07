setlocal spell
setlocal expandtab
setlocal autoindent
setlocal textwidth=0
setlocal formatoptions=12crqnw
setlocal comments=n:>
" setlocal wrap
setlocal breakindent
setlocal breakindentopt=min:50,shift:2
setlocal commentstring=<!--%s-->

let b:ncm2_look_enabled = 1
let b:autopairs_skip = ["'"]

" nnoremap <silent> <buffer> gf :call wiki#follow(0)<CR>
" nnoremap <silent> <buffer> gF :call wiki#follow(1)<CR>
" nnoremap <silent> <buffer> gl :<C-u>set opfunc=wiki#create_link<CR>g@
" xnoremap <silent> <buffer> gl <esc>:<C-u>call wiki#create_link()<CR>

imap <c-x><c-i> <plug>(citebib-complete)
" vim: set ts=2 sw=2 tw=99 et :
