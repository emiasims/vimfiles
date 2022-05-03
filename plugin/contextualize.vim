" My contextualize.vim setting

try
  packadd contextualize.vim
catch
  finish
endtry

Contextualize {-> vsnip#expandable()} imap <Tab> <Plug>(vsnip-expand)
Contextualize {-> vsnip#jumpable(1)} imap <Tab> <Plug>(vsnip-jump-next)
Contextualize {-> vsnip#jumpable(1)} smap <Tab> <Plug>(vsnip-jump-next)
Contextualize {-> vsnip#jumpable(-1)} imap <S-Tab> <Plug>(vsnip-jump-prev)
Contextualize {-> vsnip#jumpable(-1)} smap <S-Tab> <Plug>(vsnip-jump-prev)

Contextualize {-> luaeval("require'cmp'.visible()")} imap <Cr> <Plug>(miaConfirmCmp)

function! s:startcmd() abort dict
  return getcmdtype()==":" && getcmdline()==self.lhs
endfunction
ContextAdd startcmd s:startcmd

ContextAdd inSyntax {name -> match(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), name) >= 0}

Contextualize startcmd cnoreabbrev he help
Contextualize startcmd cnoreabbrev h vert help
Contextualize startcmd cnoreabbrev <expr> some 'mkview \| source % \| setfiletype ' . &filetype . ' \| loadview'
Contextualize startcmd cnoreabbrev <expr> vre 'mkview \| runtime! settings.vim \| setfiletype ' . &filetype . ' \| loadview'
Contextualize startcmd cnoreabbrev eft EditFtplugin
Contextualize startcmd cnoreabbrev e! mkview \| edit!
Contextualize startcmd cnoreabbrev use UltiSnipsEdit
Contextualize startcmd cnoreabbrev ase AutoSourceEnable
Contextualize startcmd cnoreabbrev asd AutoSourceDisable
Contextualize startcmd cnoreabbrev sr SetRepl
Contextualize startcmd cnoreabbrev tr TermRepl
Contextualize startcmd cnoreabbrev <expr> vga 'vimgrep / **/*.' . expand('%:e') . "\<C-Left><Left><Left>"
Contextualize startcmd cnoreabbrev cqf Clearqflist
Contextualize startcmd cnoreabbrev w2 w
Contextualize startcmd cnoreabbrev dws mkview \| silent! %s/\s\+$// \| loadview \| update
" Use this like 'eh/', the / expands and adds the dir / divider
Contextualize startcmd cnoreabbrev eh edit <C-r>=expand('%:h')<Cr>

" Start insert after opening a terminal, but also place cursor after fish so we can edit the command
Contextualize startcmd cnoreabbrev T  execute 'term fish'\|startinsert<C-left><Right><Right><Right><Right>
Contextualize startcmd cnoreabbrev term term fish

Contextualize startcmd cnoreabbrev f  Telescope fd
Contextualize startcmd cnoreabbrev o  Telescope fd cwd=~/org
Contextualize startcmd cnoreabbrev l  Telescope buffers
Contextualize startcmd cnoreabbrev t  Telescope tags
Contextualize startcmd cnoreabbrev mr Telescope oldfiles
Contextualize startcmd cnoreabbrev A  Telescope live_grep
Contextualize startcmd cnoreabbrev h  Telescope help_tags
Contextualize startcmd cnoreabbrev ev Telescope fd cwd=$CFGDIR
Contextualize startcmd cnoreabbrev evr Telescope fd cwd=/home/elsimmons/src/nvim-runtime/usr/share/nvim/runtime

" Expand with <C-]>
Contextualize startcmd cnoreabbrev c   Capture <C-z>

function! SetupSubstitute(type) abort
  call feedkeys(":'[,']s/\<C-r>\"//g\<Left>\<Left>")
endfunction " }}}
xnoremap s :s//g<Left><Left>
Contextualize {-> mode(1) =~# 'v'} xnoremap s y:set opfunc=SetupSubstitute<Cr>g@

" Autopairs
ContextAdd pairallowed {-> getline('.')[col('.') - 1] =~ '\W' || col('.') - 1 == len(getline('.'))}
ContextAdd quoteallowed {-> getline('.')[col('.') - 2 : col('.') - 1] !~ '\w'}
ContextAdd completepair {lhs -> getline('.')[col('.') - 1] == lhs}
ContextAdd inpair {-> getline('.')[col('.') - 2 : col('.')] =~ '^\%(\V()\|{}\|[]\|''''\|""\)'}

function! s:closingpairs(...) abort
  return getline('.')[col('.') - 1 :] =~ '^' . (get(a:, 1, '') . '[\]''")}]\+')
endfunction
ContextAdd closingpairs s:closingpairs

for pair in ['()', '[]', '{}']
  call contextualize#map('pairallowed' , 'i', 'map', pair[0], pair . '<C-g>U<Left>')
  call contextualize#map('pairallowed' , 's', 'map', pair[0], pair . '<C-g>U<Left>')
  call contextualize#map('completepair', 'i', 'map', pair[1], '<C-g>U<Right>', {'args': pair[1]})
  call contextualize#map('closingpairs ' . pair[1], 'i', 'map', pair[1], '<C-o>f' . pair[1] . '<Right>')
endfor

Contextualize closingpairs inoremap <Tab> <C-o>/[^\]''")}]\\|$/e<Cr>

" Complete should take prescedence for quotes
Contextualize completepair ' inoremap ' <C-g>U<Right>
Contextualize completepair " inoremap " <C-g>U<Right>
Contextualize quoteallowed inoremap ' ''<C-g>U<Left>
Contextualize quoteallowed inoremap " ""<C-g>U<Left>
Contextualize quoteallowed snoremap ' ''<C-g>U<Left>
Contextualize quoteallowed snoremap " ""<C-g>U<Left>

Contextualize inpair inoremap <Bs> <BS><Del>
Contextualize inpair inoremap <Cr> <Cr><C-c>O
Contextualize inpair inoremap <Space> <Space><Space><C-g>U<Left>
" Contextualize {-> getline('.')[col('.') - 2 : col('.')] =~ '^\%(\V(  )\|{  }\|[  ]\|''  ''\|"  "\)'} inoremap <Bs> <BS><Del>

ContextAdd pumvis pumvisible
" Contextualize pumvis inoremap <Cr> <C-y>
Contextualize pumvis inoremap <Esc> <C-e>

" vim-fugitive
Contextualize startcmd cnoreabbrev gcim Gcommit \| startinsert
