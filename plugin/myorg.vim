" Hooks {{{1
function! s:dosnippet() abort " {{{2
  if !has_key(g:org#currentcapture, 'snippet')
    return
  endif
  if type(g:org#currentcapture.snippet) == v:t_list
    let snippet = join(g:org#currentcapture.snippet, "\n")
  else
    let snippet = g:org#currentcapture.snippet
  endif
  let parts = split(snippet, '`', 1)  " break up backticks

  " Eval places with !o (!v and !p are used for vim and python within the snippet)
  " !o is used for the context of evaluating the snippet (ie. expand('%') gives the captured-in)
  for ix in range(1, len(parts) - 1, 2)
    let parts[ix] = parts[ix] =~# '^!o ' ? eval(parts[ix][3:]) : '`' . parts[ix] . '`'
  endfor
  let snippet = substitute(join(parts, ''), "'", "''", 'g')
  let snippet = substitute(snippet, "\n", "\<C-v>\n", 'g')

  let g:org#currentcapture.template = '* snippet'
  let g:org#currentcapture.snippet = "A\<C-r>=UltiSnips#Anon('" . snippet . "', 'snippet')\<Cr>"
  autocmd User OrgCapturePost ++once call feedkeys(g:org#currentcapture.snippet, 'nx')
endfunction " }}}

augroup vimrc_org " {{{2
  autocmd!
  " normal! seems to conflict with the feedkeys command
  " autocmd User OrgCapturePost if (! g:org#currentcapture.opts.quit) && !has_key(g:org#currentcapture, 'snippet') | normal! zMzvzz | endif
  autocmd User OrgCapturePre call <SID>dosnippet()
  autocmd User OrgRefilePre if g:org#refile#destination.filename =~# 'archive.org$' | call org#plan#add({'CLOSED': '[now]'}) | endif
augroup END

" Capture templates {{{1
let g:org#capture#templates = {}
let t = g:org#capture#templates
let t.q = {'type': 'entry', 'description': 'Quick', 'target': 'inbox.org', 'snippet': ['${0:Idea}']}
let t.n = {'type': 'entry', 'description': 'Note', 'target': 'inbox.org'}
let t.e = {'type': 'entry', 'description': 'Event', 'target': 'events.org'}
let t.e.snippet = ['${1:Event}', '<${2:today}>']

let t.b = {'type': 'entry', 'description': 'Shopping item', 'target': 'todo.org/Shopping'}
let t.b.snippet =<< ENDORGTMPL " {{{2
${0:I NEEEED IT}
:PROPERTIES:
:captured-at: `!v org#timestamp#date2text(localtime())`
:captured-in: `!o resolve(fnamemodify(expand('%'), ':p:~'))`
:END:
ENDORGTMPL
" }}}

let t.dj = {'type': 'entry', 'description': 'Journal'}
let t.dj.target = {-> 'diary.org/' . strftime('%B/%A the ') . (strftime('%d')+0) . (strftime('%d')  =~ '1[123]' ? 'st' : get({1: 'st', 2: 'nd', 3: 'rd'}, strftime('%d') % 10, 'th'))}
" The time is now - 3 hours -- allows going to bed at 3 am
let t.dj.snippet =<< ENDORGTMPL " {{{2
Journal
[`!v org#time#dict(localtime() - 3600 * 3).totext('T')`]
:PROPERTIES:
:food+: $1
:games+: $2
:exercise: $3
:reading: $4
:END:

  - Today I am thankful for      :: $5
  - Today I have been dreading   :: $6
  - Today I felt good about      :: $7
  - Something I did well at      :: $8
  - Something I could improve at :: $9

$0
ENDORGTMPL
" }}}

let t.ds = {'type': 'entry', 'description': 'Sleep log'}
let t.ds.target = {-> 'diary.org/' . strftime('%B/%A the ') . (strftime('%d')+0) . (strftime('%d')  =~ '1[123]' ? 'st' : get({1: 'st', 2: 'nd', 3: 'rd'}, strftime('%d') % 10, 'th'))}
let t.ds.snippet =<< ENDORGTMPL " {{{2
Sleep log
[`!v org#time#dict('today').totext()`]
:PROPERTIES:
:screen-off: ${1:10:30} pm
:bedtime: ${2:10:30} am
:waketime: ${3:10:30} am
:uptime: ${4:10:30} am
:sleep-time: 7.5 h
:restless-time: 7.5 h
:quality: ${6:good}
:quantity: ${7:good}
:END:

$0
ENDORGTMPL
" }}}

let t.r = {'type': 'entry', 'description': 'Recipe', 'snippet': 1}
" let t.t = {'type': 'entry', 'description': 'Recipe', 'snippet': 1, 'context': 'expand("%") =~# ''food\.org'''}
let t.r.snippet =<< ENDORGTMPL " {{{2
${1:Recipe}
:PROPERTIES:
:source: ${1:URL}
:servings: ${2:nservings}
:prep-time: ${3:30m}
:cook-time: ${4:30m}
:total-time: ${5:1h}
:END:
** Ingredients
${6}

** Directions
${7}

ENDORGTMPL
" }}}

nmap <leader>c <Plug>(org-capture)
xmap <leader>c <Plug>(org-capture)
nmap <leader>q <Plug>(org-capture)q
unlet t

let g:org#capture#opts = {'editcmd': 'JumpSplitOrEdit'}

" Other settings {{{1

let g:org#agenda#filelist = [fnamemodify('~/org/todo.org', ':p')]

" Inbox {{{1
command! ProcessInbox call s:processInbox()

function! s:processInbox() abort " {{{2
  JumpOrEdit $HOME/org/inbox.org
  let headlines = map(org#outline#file('inbox').subtrees, 'v:val[0]')
  call filter(headlines, '!empty(v:val.todo . v:val.done)')
  for hl in headlines
    execute hl.cmd
    call myorg#processInboxItem(hl)
    update
    buffer inbox.org
    update
  endfor
endfunction

function! myorg#processInboxItem(...) abort " {{{2
  let hl = exists('a:1') ? a:1 : org#headline#get('.')
  let hl = type(hl) == v:t_dict ? hl : org#headline#get(hl)
  if hl.todo ==# 'PROJECT'  " {{{3
    if index(hl.tags, 'project') < 0
      let headline = input('Headline> ', hl.item)
      let tags = split(input("\n(Space separated)\nTags> ", 'project '))
      call org#headline#addtag('project')
    endif
    call org#keyword#set('')
    call org#headline#add(hl.level + 1, 'NEXT Add actionable items')
    call org#refile('todo.org')
  elseif hl.todo ==# 'EVENT'  " {{{3
    if empty(org#plan#get('.'))
      let headline = input('Headline> ', hl.item)
      let time = input('Timestamp> ')
      call org#headline#set(headline)
      call org#plan#set(hl.lnum, {'TIMESTAMP': org#time#dict(time)})
    endif
    call org#refile('events.org')
  elseif hl.todo ==# 'ACTIONABLE'  " {{{3
    let targets = org#outline#file('todo.org')
    let g:org#outline#complete#targets = filter(targets.list, 'index(v:val.tags, "project") >= 0')
    call map(g:org#outline#complete#targets, 'v:val.target')
    echo 'Processing:'
    echo hl.text
    let target = input('Refile to project> ', 'todo.org', 'customlist,org#outline#complete')
    call org#keyword#set('TODO')
    " call org#headline#add(hl.level + 1, 'NEXT Add actionable items')
    " TODO if refile target did not exist, make it a project.
    call org#refile(target)
  elseif hl.todo ==# 'INACTIONABLE'  " {{{3
    " call s:add_actionable
    " Remove keyword
    " Add NEXT Add actionable items
    let targets = org#outline#file('todo.org')
    let g:org#outline#complete#targets = filter(targets.list, 'index(v:val.tags, "project") >= 0')
    call map(g:org#outline#complete#targets, 'v:val.target')
    echo 'Processing:'
    echo hl.text
    let target = input('Refile to project> ', 'todo.org', 'customlist,org#outline#complete')
    call org#headline#add(hl.level + 1, 'NEXT Add actionable items')
    call org#refile(target)
  elseif hl.todo ==# 'SOMEDAY' || hl.todo ==# 'MAYBE'  " {{{3
    call org#refile('later.org')
  elseif hl.todo ==# 'NOTE'  " {{{3
    call org#refile('notebox.org')
  elseif hl.todo ==# 'NOW'  " {{{3
    call org#keyword#set('NEXT')
    call org#refile('todo.org/Do it do it do it')
  elseif hl.done ==# 'DONE'  " {{{3
    call org#refile('archive.org')
  endif " }}}
endfunction
