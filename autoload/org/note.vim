function! org#note#add(headline, ...) abort " {{{1
  if exists('a:1')
    call org#note#addlink(org#note#getlink(a:1))
  endif
  call org#headline#add(1, a:headline)
  call org#keyword#set('NEXT')
  call org#property#add({'CUSTOM_ID': org#note#generateid(a:headline)})
endfunction

function! org#note#followLink() abort " {{{1
  " get text -- match pattern

  let text = split(getline('.')[: col('.') - 2], '\ze[[')[-1]
  let text .= split(getline('.')[col('.') - 1 :], ']]\zs')[0]
  if text !~ '^\[\[[^][]*\]\%(\[[^][]*\]\)\]$' 
    try
      echoerr 'Nope:' text
    endtry
  endif
  let uri = matchstr(text, '^\[\[\zs[^][]*\ze\]\%(\[[^][]*\]\)\]$')
  if uri =~# '^#'
    " Better to search the outline for this?
    normal! m`
    let ln = org#util#search(1, '^\s*:CUSTOM_ID:\s*#' . uri[1:], 'nW')
    call org#util#search(ln, '^\*', 'bW')
  elseif uri =~# '^file:'
    call util#openf(uri[5:])
  elseif filereadable(uri)
    call util#openf(uri)
  elseif uri =~# '^https\?:'
    call util#openf(uri)
  else
    echoerr 'Not sure how to handle link:' uri
  endif


  " links:
  " 'http://www.astro.uva.nl/=dominik'         on the web
  " 'file:/home/dominik/images/jupiter.jpg'    file, absolute path
  " '/home/dominik/images/jupiter.jpg'         same as above
  " 'file:papers/last.pdf'                     file, relative path
  " './papers/last.pdf'                        same as above
  " 'file:projects.org'                        another Org file
  " 'id:B7423F4D-2E8A-471B-8810-C40F074717E9'  link to heading by ID
  " 'mailto:adent@galaxy.net'                  mail link

  " File links can contain additional information to make Emacs jump to a particular location in the file when following a link. This can be a line number or a search option after a double colon. Here are a few examples,, together with an explanation:
  " 'file:~/code/main.c::255'                  Find line 255
  " 'file:~/xx.org::My Target'                 Find '<<My Target>>'
  " '[[file:~/xx.org::#my-custom-id]]'         Find entry with a custom ID


endfunction


function! org#note#setupLink(type, ...) abort range " {{{1
  " Mark note
  let [lnum, col_start] = getpos(a:0 > 0 ? "'<" : "'[")[1:2]
  let [line_end, col_end] = getpos(a:0 > 0 ? "'>" : "']")[1:2]
  if lnum != line_end
    throw 'NYI for multiple lines: ' . lnum . ', ' . line_end
  endif
  let text = getline(lnum)
  let name = text[col_start - 1 : col_end - 1]
  let id = org#note#generateid(name)
  call setline(lnum, text[: col_start - 2] . '[[#' . id . ']['. name . ']]' . text[col_end :])

  let next = org#headline#find('.', 1, 'xnW')
  let next = next == 0 ? prevnonblank(line('$')) : next - 1

  call append(next, id . ' ' . name . ' ,newnote') " snippet
  execute next+1
  call feedkeys("A\<Tab>")
endfunction


function! s:plan_repeats(headline) abort " {{{2
  for kind in ['TIMESTAMP', 'DEADLINE', 'SCHEDULED']
    if has_key(a:headline.plan, kind) && !empty(a:headline.plan[kind].repeater)
      return 1
    endif
  endfor
  return 0
endfunction

function! org#note#addid() abort " {{{1
  " Expected to be used via autocmd
  if !org#headline#find('.', 0, 'nbW')
    return
  endif
  let properties = {'last-update': org#time#dict('[now]').totext('t')}
  let current = org#property#all('.') 
  if !has_key(current, 'CUSTOM_ID')
    let properties.CUSTOM_ID = org#note#generateid(org#headline#get('.').item)
  endif
  if !has_key(current, 'created-at')
    let properties['created-at'] = org#time#dict("[now]").totext("t")
  endif
  call org#property#add(properties)
endfunction

function! org#note#addlink(id, ...) abort " {{{1
  " Ensure link exists
  " Add list item in links section
  let lnum = org#headline#level('.') == 1 ? line('.') : org#headline#find('.', 1, 'bW')
  call org#property#add(lnum, {'link+': id})
endfunction

function! org#note#fromhl(headline) abort " {{{1
  " Meant to be used in OrgRefilePre
  execute 'buffer +' . a:headline.lnum a:headline.bufnr
  let id = org#note#generateid(a:headline.item)
  call org#keyword#set('NEXT', 1)
  call org#property#add({'CUSTOM_ID': id}, 0)
  if !has_key(org#property#all('.'), 'created-at')
    call org#property#add({'created-at': org#time#dict("[now]").totext("t")})
  endif
endfunction

function! org#note#fzfcompl() abort " {{{1
  " FIXME if there are edits and org tries to parse a file in compl mode, it won't allow it to
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
        \ 'reducer': function('s:makelink'),
        \ 'options': '--multi'}))
endfunction

function! s:makelink(selections) abort " {{{2
  if len(a:selections) > 1
    return join(map(a:selections, '"[[" . split(v:val)[-1] . "]]"'), '')
  endif
  let [name, id] = split(a:selections[0], '\s\+\ze\S\+$')
  return '[[id:' . id . '][' . name . "]]"
endfunction

function! org#note#generateid(headline, ...) abort " {{{1
  " Why? Because I like how it looks.
  let id = sha256(strftime('%Y%m%d%H%M', get(a:, 1, localtime())) . a:headline)
  let [a, b, c] = matchlist(id, '\v(\w)\d*(\w)\d*(\w)\d*$')[1:3]
  return toupper(a . '-' . b . c) . '-' . id[:12]
endfunction

function! org#note#getlink(lnum) abort " {{{1
  " Ensure link exists
  " Add list item in links section
  let lnum = org#headline#level(a:lnum) == 1 ? a:lnum : org#headline#find(a:lnum, 1, 'bW')
  let id = org#property#get(lnum, 'CUSTOM_ID')
  if empty(id)
    throw 'No id found at line ' . a:lnum
  endif
  return id
endfunction

function! org#note#links() abort " {{{1
  let links = map(org#outline#file('notebox.org').subtrees, 'v:val[0]')
  call map(links, '{"word": v:val.properties.CUSTOM_ID, "abbr": v:val.item, "menu": join(v:val.tags)}')
  return links
endfunction

" function! org#note#make_inserted_links() abort " {{{1
"   let text = @.
"   if getregtype() !~? 'v' || @. !~ '\[\[[^][]*\]\]'
"     return
"   endif
"   " check if this uri exists or matches a uri schema. If so, do nothing
"   " Otherwise
" endfunction

function! org#note#newwithlink() abort " {{{1
  let link = org#headline#get('.').properties.CUSTOM_ID
  let name = input('Note> ')
  " let 
endfunction
