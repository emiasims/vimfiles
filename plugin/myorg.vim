" Hooks {{{1

augroup vimrc_org
  autocmd!
  autocmd User OrgAgendaBuildPre call myorg#process_repeats()
  autocmd User OrgCapturePre call myorg#dosnippet()
  autocmd User OrgCapturePost if has_key(g:org#currentcapture, 'snippet') | call feedkeys(g:org#currentcapture.snippet, 'nx') | endif
  autocmd User OrgCapturePost call org#property#add({'created-at': org#time#dict("[now]").totext("t")})
  autocmd User OrgCapturePost call org#property#add({'created-at': org#time#dict("[now]").totext("t")})
  autocmd User OrgRefilePre if g:org#refile#destination.filename =~# 'archive.org$' | call org#plan#add({'CLOSED': '[now]'}) | endif
  autocmd InsertLeave *.org if org#listitem#has_ordered_bullet(getline('.'))|call org#list#reorder()|endif

  autocmd User OrgRefilePost silent update|buffer #
  autocmd User OrgRefilePost echo 'Refiled to' org#headline#astarget(g:org#refile#destination)
augroup END

" Capture templates {{{1
let g:org#capture#templates = {}
let t = g:org#capture#templates
let t.q = {'description': 'Quick', 'type': 'entry', 'target': 'inbox.org', 'snippet': ['${1:Idea}']}
let t.v = {'description': 'Voice phrase', 'type': 'item', 'target': 'ongoing.org/Transition/Voice/Phrases', 'snippet': ['${1:words}']}
let t.n = {'description': 'Note', 'type': 'entry', 'target': 'notebox.org', 'snippet': ['${1:Note}']}
let t.op = {'description': 'Org pain point', 'type': 'entry'} " {{{2
let t.op.target = 'ongoing.org/vim-org'
let t.op.snippet = ['${1:It''s bothersome when...} :pain:']

let t.oi = {'description': 'Org idea', 'type': 'entry'} " {{{2
let t.oi.target = 'ongoing.org/vim-org'
let t.oi.snippet = ['${1:It would be neat if...} :idea:']

let t.e = {'description': 'Event', 'type': 'entry', 'target': 'events.org'} " {{{2
let t.e.snippet = ['${1:Event}', '<${2:`!v org#time#dict("today").totext("B")`}>', '$0']

let t.dj = {'description': 'Journal', 'type': 'entry'} " {{{2
let t.dj.target = {-> 'diary.org/' . strftime('%B/%A the ') . (strftime('%d')+0) . (strftime('%d')  =~ '1[123]' ? 'st' : get({1: 'st', 2: 'nd', 3: 'rd'}, strftime('%d') % 10, 'th'))}
" The time is now - 3 hours -- allows going to bed at 3 am
let t.dj.snippet =<< ENDORGTMPL
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

${10:Dear} Emilia,

${11:~~emotions~~}

${12:xoxo}
ENDORGTMPL

let t.ds = {'description': 'Sleep log', 'type': 'entry'} " {{{2
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

let t.r = {'description': 'Recipe', 'type': 'entry', 'target': 'recipes.org'} " {{{2
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

nmap <leader>c <Plug>(org-capture)
xmap <leader>c <Plug>(org-capture)
unlet t

let g:org#capture#opts = {'editcmd': 'JumpSplitOrEdit'}

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
command! OrgNext call org#agenda#toqf(<SID>getkwd('NEXT')) | copen
command! OrgTodo call org#agenda#toqf(<SID>getkwd('TODO')) | copen

let g:org#agenda#wincmd = 'SmartSplit'
" let g:org#agenda#wincmd = 'keepalt topleft 80 vsplit'
let g:org#agenda#filelist = map(['todo.org', 'events.org'], "fnamemodify('~/org/' . v:val, ':p')")

let g:org#agenda#views = {'today': [
      \ {'title': 'Weekly Agenda',
      \  'filter': 'org#plan#within(v:val.plan, "+7d") && index(v:val.tags, "habit") < 0',
      \  'sorter': {a, b -> org#time#diff(org#plan#nearest(a.plan), org#plan#nearest(b.plan))},
      \  'display': 'datetime'},
      \ {'title': 'Habits', 'filter': {_, hl -> index(hl.tags, 'habit') >= 0 && org#plan#within(hl.plan, 'today')}},
      \ ],
      \ 'work': [
      \ {'title': 'LATE', 'filter': {_, hl -> org#plan#islate(hl.plan) && org#plan#nearest(hl.plan).active}},
      \ {'title': 'Projects', 'generator': 'myorg#project_generator', 'filter': 'myorg#project_filter(v:val)', 'separator': 'myorg#project_separator'},
      \ {'title': 'TODO', 'generator': 'myorg#project_generator', 'filter': {_, hl -> !hl.done && !empty(hl.keyword) && !myorg#project_filter(hl) && index(hl.tags, 'habits') < 0}, 'files': ['todo.org']},
      \ ],
      \ 'personal': [
      \ {'title': 'LATE', 'filter': {_, hl -> org#plan#islate(hl.plan) && org#plan#nearest(hl.plan).active}},
      \ {'title': 'Projects', 'generator': 'myorg#project_generator', 'filter': 'myorg#project_filter(v:val)', 'separator': 'myorg#project_separator'},
      \ {'title': 'TODO', 'filter': {_, hl -> !hl.done && !empty(hl.keyword)}, 'files': ['todo.org']},
      \ ],
      \ 'notes': [
      \ {'title': 'Next', 'filter': {_, hl -> hl.keyword == 'NEXT'}},
      \ {'title': 'Needs review', 'filter': {_, hl -> hl.keyword == 'REVIEW' && org#plan#within(hl.plan, '+7d')}},
      \ ],
      \ }

" used in after/ftplugin/agenda.vim
nnoremap <F5> :let g:last_agenda='today'\|call org#agenda#build('today')<Cr>
nnoremap <F6> :let g:last_agenda='work'\|call org#agenda#build('work')<Cr>
nnoremap <F7> :let g:last_agenda='personal'\|call org#agenda#build('personal')<Cr>

let g:org#agenda#jump = 'SmartSplit'

highlight link orgAgendaTitle Statement
highlight link orgAgendaDate Function
highlight link orgAgendaFile Identifier
highlight link orgAgendaPlan Comment
highlight link orgAgendaKeyword Todo
highlight link orgAgendaHeadline Normal
highlight link orgAgendaAttention Error

command! Review call myorg#review()
command! -bang -nargs=* Archive call myorg#archive(<bang>0)
