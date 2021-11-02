" Hooks {{{1

augroup vimrc_org
  autocmd!
  autocmd User OrgAgendaBuildPre call myorg#process_repeats()
  autocmd User OrgCapturePre call myorg#dosnippet()
  autocmd User OrgCapturePost if has_key(g:org#currentcapture, 'snippet') | call feedkeys(g:org#currentcapture.snippet, 'nx') | endif
  autocmd User OrgCapturePost call org#property#add({'created-at': org#time#dict("[now]").totext("t")})
  autocmd User OrgRefilePre if g:org#refile#destination.filename =~# 'archive.org$' | call org#plan#add({'CLOSED': '[now]'}) | endif
  autocmd InsertLeave *.org call v:lua.mia.org.list.reorder()

  autocmd User OrgRefilePost echo 'Refiled to' org#headline#astarget(g:org#refile#destination)
  autocmd User OrgRefilePost silent update|buffer #

  autocmd User OrgKeywordDone call myorg#completeTaskInJournal()

  autocmd Syntax org call SyntaxRange#Include('^\s*#+BEGIN_SRC python\s*', '^\s*#+END_SRC', 'python')
augroup END

" Capture templates {{{1
let g:org#capture#templates = #{
      \ q: #{description: 'Quick', snippet: ['${1:Title}', '$0']},
      \ t: #{description: 'Todo', snippet: ['TODO ${1:Title}', '$0']},
      \ c: #{description: 'Chore', target: 'chores.org',
      \      snippet: ['TODO ${1:Chore}', "`!v org#time#dict('today').totext('T')`"]},
      \ e: #{description: 'Event', target: 'events.org',
      \      snippet: ['${1:Event}', '<${2:`!v org#time#dict("today").totext("B")`}>', '$0']},
      \ r: #{description: 'Recipe', target: 'recipes.org', snippet: ['${1:Recipe}', '$0']},
      \ }

nnoremap \c :call myorg#capture()<Cr>
xnoremap \c :<C-u>call myorg#capture()<Cr>

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

function! s:block_display(hl) abort " {{{2
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
  if org#plan#islate(a:hl.plan)
    let datecolor = 'Exception'
  elseif org#plan#within(a:hl.plan, 'today')
    let datecolor = 'Type'
  else
    let datecolor = 'orgAgendaPlan'
  endif
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
      \ #{title: 'Today', filter: "PLAN<='today'-DONE", display: 'datetime', sorter: 'PLAN'},
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
command! -nargs=? MakePlan call myorg#makeplan(<f-args>)
