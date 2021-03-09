setlocal colorcolumn=100
setlocal spell
let b:cursorword = 0
setlocal foldminlines=0
setlocal concealcursor=n

nmap <buffer> gO <Plug>(org-headline-open-above)Headline<Esc>[ viw<C-g>
nmap <buffer> go <Plug>(org-headline-open-below)Headline<Esc>[ viw<C-g>

ContextAdd <buffer> indrawer {-> org#property#isindrawer('.')}
Contextualize indrawer inoremap <buffer> ; property<C-r>=UltiSnips#Anon(":${1:prop}: ${0:val}", "property")<Cr>

nnoremap <buffer> \d :call org#keyword#set(org#outline#keywords().done[-1])<Cr>

ContextAdd <buffer> startoflist {-> getline('.') =~ '\v^\s*' . g:org#regex#list#bullet . '\s*$'}
Contextualize startoflist inoremap <buffer> <expr> [ '[ ] '
Contextualize default imap <buffer> <expr> [ g:contextualize.i.map['['].do()

ContextAdd <buffer> linkend {-> getline('.')[: col('.') - 2] =~ '\[\[[^\[\]]*\]\[[^\[\]]*\]\]$'}
ContextAdd <buffer> inlink {-> getline('.')[col("'>") : col("'>")+1] == ']]'}
Contextualize inlink snoremap <buffer> <Tab> <Esc>2f]a
Contextualize linkend inoremap <buffer> <Tab> <Esc>hhvi]<C-g>
Contextualize default imap <buffer> <expr> <Tab> g:contextualize.i.map['<lt>tab>'].do()

Contextualize inSyntax orgLink nmap <buffer> K <Plug>(org-follow-link)
" xnoremap <silent> <buffer> K :<C-u>call notebox#setupLink('', 'v')<Cr>
