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

augroup vimrc_org
  autocmd!
  " normal! seems to conflict with the feedkeys command
  " autocmd User OrgCapturePost if (! g:org#currentcapture.opts.quit) && !has_key(g:org#currentcapture, 'snippet') | normal! zMzvzz | endif
  autocmd User OrgCapturePre call <SID>dosnippet()
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

function! s:echo(hl) abort " {{{2
  echo a:hl
endfunction
let g:org#inbox#opts = {
      \ 'c': {'desc': 'Create project'  , 'func': function('s:echo')},
      \ 'e': {'desc': 'Event'           , 'func': function('s:echo')},
      \ 'a': {'desc': 'Actionable item+', 'func': function('s:echo')},
      \ 'i': {'desc': 'Inoperable item*', 'func': function('s:echo')},
      \ 'l': {'desc': 'Someday later'   , 'func': function('s:echo')},
      \ 'm': {'desc': 'Maybe later'     , 'func': function('s:echo')},
      \ 'z': {'desc': 'Create note*'    , 'func': function('s:echo')},
      \ 'd': {'desc': 'Do now*'         , 'func': function('s:echo')}
      \ }
let g:org#inbox#text = ['* Refile into "Process Now"', '+ Refile into a project (prompt)']

function! s:new_project(hl) abort " {{{2
  " Prompt for headline, filling in with hl.item
  " Prompt for tags, fill with :project: complete with #+TAGS:
  " prompt for actionable items, if non are added, add: NEXT Add actionable items
endfunction

function! s:new_event(hl) abort " {{{2
  " Prompt for headline
  " Add timestamp
endfunction

function! s:add_actionable(hl) abort " {{{2
  " Prompt for projects in todo, and complete proj names.
  " Prompt for headline
  let g:org#outline#complete#filter = 'v:val.level == '
endfunction

function! s:add_inoperable(hl) abort " {{{2
  " call s:add_actionable
  " Remove keyword
  " Add NEXT Add actionable items
endfunction

function! s:add_someday(hl) abort " {{{2
  " Refile to later, add keyword
  call s:add_kwd_and_refile(a:hl, 'SOMEDAY', 'later.org')
endfunction

function! s:add_maybe(hl) abort " {{{2
  " Refile to later, add keyword
  call s:add_kwd_and_refile(a:hl, 'MAYBE', 'later.org')
endfunction

function! s:add_note(hl) abort " {{{2
  " Create unique ID
  " Refile with NEXT keyword
  " Ask for tags
  " Set up hl for related ideas. list in subtree?
endfunction

function! s:add_donow(hl) abort " {{{2
  " Refile to todo with NEXT
  call s:add_kwd_and_refile(a:hl, 'NEXT', 'todo.org/Do it do it do it')
endfunction

function! s:add_kwd_and_refile(hl, kwd, dest) abort " {{{2
  execute 1 . a:hl.cmd
  " TODO org#headline#update
  call setline('.', join(insert(split(getline('.')), a:kwd, 1)))
  call org#refile(a:dest)
  write
  buffer inbox.org
  write
endfunction

function! s:processInbox() abort " {{{2

  JumpOrEdit $HOME/org/inbox.org

  " Set up menu text
  let opttext = "-=-=-=-=-=-=-=-=-=-=-=-\n"
  let colw = max(map(copy(g:org#inbox#opts), 'len(v:val.desc)')) + 7
  let maxw = 60
  let defaults = ['n: Next (skip)', 'p: Previous', 't: Trash', 'q: Quit & apply', 'Q: Abandon changes']

  let width = 0
  for opt in map(items(g:org#inbox#opts), 'v:val[0] . ": " . v:val[1].desc') + defaults
    let opttext .= opt . ((width + colw < maxw) ? repeat(' ', colw - len(opt)) : "\n")
    let width = (width + colw < maxw) ? width + colw : 0
  endfor

  let charregex = '[' . join(keys(g:org#inbox#opts), '') . 'nptqQ' . ']'

  let i = 0
  let headlines = map(copy(org#outline#file('inbox').subtrees), 'v:val[0]')
  let selections = repeat(['n'], len(headlines))
  while i < len(headlines)
    let hl = headlines[i]

    " Show headline
    execute '1' . (hl.lnum > 1 ? hl.cmd : '')
    nohlsearch
    normal! zMzvzz
    redraw

    " Prompt for Refile target, but allow for shortcuts
    let range = org#section#range(hl.lnum)
    let lines = getline(range[0], range[1])
    echohl Statement
    echo lines[0]
    echohl None
    echo join(lines[1:], "\n")
    echohl Comment
    echo opttext
    echohl None
    echo '> '
    let selection = nr2char(getchar())

    " Process & store selection
    if selection == 'q'
      redraw
      break
    elseif selection == 'Q'
      redraw
      return
    elseif selection !~? charregex
      echohl Error
      echo selection 'is not an option. Press q to quit'
      echohl None
      continue
    endif
    redraw
    let selections[i] = selection == 'n' ? 's' : selection
    let i += selection == 'p' ? -1 : 1
  endwhile


  let actions = map(copy(g:org#inbox#opts), '[]')
  " let actions = map(copy(g:org#inbox#opts), 'filter(copy(selections), "''" . v:key . "''== v:val")')
  for i in range(len(selections))
    if has_key(actions, selections[i])
      call add(actions[selections[i]], i)
    endif
  endfor

  " Batch process each:
  for [key, hlix] in items(actions)
    echohl Comment
    echo g:org#inbox#opts[key].desc . ':'
    echohl None
    call g:org#inbox#opts[key].func(headlines[hlix])
  endfor

  " Agenda: NEXT items
endfunction

" ProcessInbox shortcuts:
" New project
" project actionable item: prompt keyword
" Someday
" Maybe
" Do right now (todo.org/quick)
" New zettelkasten
" Event -- prompt date
