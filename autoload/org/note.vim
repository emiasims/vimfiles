function! org#note#add(headline, ...) abort " {{{1
  if exists('a:1')
    call org#note#addlink(org#note#getlink(a:1))
  endif
  call org#keyword#set('NEXT')
  call org#headline#add(0, 1, a:headline)
  call org#property#add('.', {'id': org#note#generateid(a:headline)})
endfunction

function! org#note#generateid(headline, ...) abort " {{{1
  " Why? Because I like how it looks.
  let id = sha256(strftime('%Y%m%d%H%M%S', get(a:, 1, localtime())) . a:headline)
  let [a, b, c] = matchlist(id, '\v(\w)\d*(\w)\d*(\w)\d*$')[1:3]
  return toupper(a . '-' . b . c) . '-' . id[:12]
endfunction

function! org#note#addlink(id, ...) abort " {{{1
  " Ensure link exists
  " Add list item in links section
  let lnum = org#headline#level('.') == 1 ? line('.') : org#headline#find('.', 1, 'bW')
  call org#property#add(lnum, {'link+': id})
endfunction

function! org#note#getlink(lnum) abort " {{{1
  " Ensure link exists
  " Add list item in links section
  let lnum = org#headline#level(a:lnum) == 1 ? a:lnum : org#headline#find(a:lnum, 1, 'bW')
  let id = org#property#get(lnum, 'id')
  if empty(id)
    throw 'No id found at line ' . a:lnum
  endif
  return id
endfunction

function! org#note#fromhl(headline) abort " {{{2
  execute headline.cmd
  let id = org#note#generateid(a:headline.item)
  call org#keyword#set('NEXT')
  call org#property#add({'id': id}, 0)
endfunction

function! org#note#newwithlink() abort " {{{2
  let link = org#headline#get('.').properties.id
  let name = input('Note> ')
  " let 
endfunction

function! org#note#links() abort " {{{2
  let links = map(org#outline#file('notebox.org').subtrees, 'v:val[0]')
  call map(links, '{"word": v:val.properties.id, "abbr": v:val.item, "menu": join(v:val.tags)}')
  return links
endfunction

function! org#note#fzfcompl() abort " {{{2
  " FIXME: if there are edits and org tries to parse a file in compl mode, it won't allow it to
  " do an update. Do better: bufload(), getbuflines(), text properties?
  let links = org#note#links()
  let itemwidth = max(map(copy(links), 'len(v:val.abbr)')) + 3
  let tagwidth = max(map(copy(links), 'len(v:val.menu)'))

  let src = []
  for item in links
    let [iw, tw] = [repeat(' ', itemwidth - len(item.abbr)), repeat(' ', tagwidth - len(item.menu))]
    call add(src, item.abbr . iw . tw . item.menu . '   ' . item.word)
  endfor
  call fzfr#setsize(100, 15)
  return fzf#vim#complete(fzf#wrap({'source': src,
        \ 'reducer': {sel -> join(map(sel, '"[[" . split(v:val)[-1] . "]]"'), '')},
        \ 'options': '--multi'}))
endfunction


" function! org#note#inscompllinks(findstart, base) abort " {{{2
"   return filter(s:links(), 'v:val.abbr =~ a:base')
" endfunction

" set completefunc=org#note#inscompllinks
" inoremap <buffer> <expr> <c-x><c-i> org#note#fzfcompl()
