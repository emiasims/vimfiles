" Hooks {{{1

augroup vimrc_org
  autocmd!
  autocmd User OrgAgendaBuildPre call myorg#process_repeats()
  autocmd User OrgCapturePre call myorg#dosnippet()
  autocmd User OrgCapturePost if has_key(g:org#currentcapture, 'snippet') | call feedkeys(g:org#currentcapture.snippet, 'nx') | endif
  autocmd User OrgCapturePost call org#property#add({'created-at': org#time#dict("[now]").totext("t")})
  autocmd User OrgRefilePre if g:org#refile#destination.filename =~# 'archive.org$' | call org#plan#add({'CLOSED': '[now]'}) | endif
  autocmd InsertLeave *.org if org#listitem#has_ordered_bullet(getline('.'))|call org#list#reorder()|endif

  autocmd User OrgRefilePost echo 'Refiled to' org#headline#astarget(g:org#refile#destination)
  autocmd User OrgRefilePost silent update|buffer #

  autocmd User OrgKeywordDone call myorg#completeTaskInJournal()

  autocmd Syntax org call SyntaxRange#Include('^\s*#+BEGIN_SRC python\s*', '^\s*#+END_SRC', 'python')
augroup END

" Capture templates {{{1
let g:org#capture#templates = {}
let t = g:org#capture#templates

let t.q = #{description: 'Quick', snippet: ['${1:Title}', '$0']}
let t.c = #{description: 'Chore', target: 'chores.org', snippet: ['TODO ${1:Chore}', "`!v org#time#dict('today').totext('T')`"]}
let t.op = #{description: 'Org note', target: 'vim-org.org', snippet: ['${1:Note}', '$0']}
let t.M = #{description: 'Medical note', target: 'health.org/Notes for Doctor', snippet: ['${1:Note}']}
let t.e = #{description: 'Event', target: 'events.org'} " {{{2
let t.e.snippet = ['${1:Event}', '<${2:`!v org#time#dict("today").totext("B")`}>', '$0']

let t.dj = #{description: 'Journal', target: function('myorg#journaltarget')} " {{{2
" The time is now - 3 hours -- allows going to bed at 3 am
let t.dj.snippet =<< ENDORGTMPL
Journal
[`!v org#time#dict(localtime() - 3600 * 3).totext('TB')`]
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

${10:Dear} Emilia,

${11:~~emotions~~}

${12:xoxo}
ENDORGTMPL

let t.ds = #{description: 'Sleep log'} " {{{2
let t.ds.target = {-> 'diary.org/' . strftime('%B/%A the ') . (strftime('%d')+0) . (strftime('%d')  =~ '1[123]' ? 'st' : get({1: 'st', 2: 'nd', 3: 'rd'}, strftime('%d') % 10, 'th'))}
let t.ds.snippet =<< ENDORGTMPL
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

let t.r = #{description: 'Recipe', target: 'recipes.org'} " {{{2
let t.r.snippet =<< ENDORGTMPL
${1:Recipe}
:PROPERTIES:
:source: ${2:URL}
:servings: ${3:nservings}
:prep-time: ${4:30m}
:cook-time: ${5:30m}
:total-time: ${6:1h}
:END:
** Ingredients
:PROPERTIES:
:${8:name}: ${9:amount}
:END:

** Directions
  1. ${0:First step}

ENDORGTMPL
" }}}

nnoremap \c :call myorg#capture()<Cr>
xnoremap \c :<C-u>call myorg#capture()<Cr>
unlet t

let g:org#capture#opts = #{editcmd: 'JumpSplitOrEdit'}

" Inbox {{{1
command! ProcessInbox call s:processInbox()

function! s:processInbox() abort
  JumpOrEdit $HOME/org/inbox.org
  let headlines = map(org#outline#file('inbox').subtrees, 'v:val[0]')
  call filter(headlines, '!empty(v:val.keyword)')
  for hl in headlines
    execute hl.cmd
    call myorg#processInboxItem(hl)
    update
    buffer inbox.org
    update
  endfor
endfunction

" Agenda {{{1

let g:org#agenda#wincmd = 'SmartSplit'

function! s:project_display(hl) abort "{{{2
  let nearest = org#plan#nearest(a:hl.plan, org#time#dict('today'), 1)
  if empty(nearest)
    let plan = '---'
  else
    let [name, time] = items(nearest)[0]
    let plan = (name =~# '^T' ? '' : name[0] . ':') . time.totext('dTR')
  endif
  let target = matchstr(a:hl.target, '[^/]*\.org/\zs.*\ze/[^/]\{-}')
  return [
        \ [plan, a:hl.keyword, a:hl.item],
        \ ['orgAgendaPlan', 'orgAgendaKeyword', 'orgAgendaHeadline'],
        \ ]
endfunction

function! s:stuck_gen() abort "{{{2
  let stuck = filter(org#outline#multi(org#agenda#files()), 'index(v:val.tags, ''project'') >= 0')
  let filter = org#agenda#filter('project-habit-DONE+NEXT')
  call filter(stuck, 'len(filter(v:val.list, "' . filter . '")) == 0')
  return values(stuck)
endfunction

function! s:stuck_display(hl) abort "{{{2
  return [[a:hl.title], ['orgAgendaDate']]
endfunction

function! s:block_display(hl) abort " {{{1
  let nearest = org#plan#nearest(a:hl.plan, org#time#dict('today'), 1)
  let plan = empty(nearest) ? '---' : keys(nearest)[0] . ':'
  if empty(nearest)
    let plan = '---'
  else
    let [name, time] = items(nearest)[0]
    let plan = (name =~# '^T' ? '' : name[0] . ':') . time.totext('dTR')
  endif
  let outline = org#outline#file(a:hl.filename)
  let title = has_key(outline, 'title') ? outline.title : a:hl.filename
  let color = has_key(outline, 'title') ? 'orgAgendaDate' : 'orgAgendaFile'
  let datecolor = org#plan#islate(a:hl.plan) ? 'orgAgendaTitle' : 'orgAgendaPlan'
  return [
        \ [title . ':', plan, a:hl.keyword, a:hl.item],
        \ [color, datecolor, 'orgAgendaKeyword', 'orgAgendaHeadline'],
        \ ]
endfunction


"}}}

" TODO how to do habits?
let g:org#agenda#views = #{
      \ projects: [
      \ #{title: 'Projects',
      \  filter: 'project-habit-DONE+KEYWORD-MEETING',
      \  separator: 'myorg#project_separator',
      \  display: function('s:project_display')},
      \ #{title: 'TODO',
      \  filter: '-project-habit-DONE+KEYWORD-CLOSED'},
      \ #{title: 'Habit',
      \  filter: 'habit'},
      \ ],
      \ planning: [
      \ #{title: 'Next', filter: 'NEXT-DONE+project', display: function('s:block_display')},
      \ #{title: 'Stuck', justify: [''],
      \  generator: function('s:stuck_gen'),
      \  display: function('s:stuck_display')},
      \ ],
      \ weekly: [
      \ #{title: 'Weekly Agenda',
      \  filter: "PLAN<='+7d'-DONE",
      \  display: 'datetime',
      \  sorter: 'PLAN'},
      \ ],
      \ }

" used in after/ftplugin/agenda.vim
nnoremap <F5> :let g:last_agenda='projects'\|call org#agenda#build(g:last_agenda)<Cr>
nnoremap <F6> :let g:last_agenda='planning'\|call org#agenda#build(g:last_agenda)<Cr>
nnoremap <F7> :let g:last_agenda='weekly'\|call org#agenda#build(g:last_agenda)<Cr>

let g:org#agenda#jump = 'JumpOrSplit'

highlight link orgAgendaTitle Statement
highlight link orgAgendaDate Function
highlight link orgAgendaFile Identifier
highlight link orgAgendaPlan Comment
highlight link orgAgendaKeyword Todo
highlight link orgAgendaHeadline Normal
highlight link orgAgendaAttention Error

let g:org#keywords = #{todo: ['TODO', 'NEXT', 'WAITING', 'MEETING'], done: ['CANCELLED', 'DONE']}

command! -bang -nargs=* Archive call myorg#archive(<bang>0)
command! -bang -nargs=* Note call myorg#new(<q-args>, <bang>0)
command! -bang -nargs=* Project call myorg#newproject(<q-args>, <bang>0)
