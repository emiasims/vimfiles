function! myorg#agenda_done() abort " {{{1
  if &filetype != 'agenda'
    throw 'Only usable in agenda filetypes'
  endif
  let lnum = line('.')
  if !has_key(b:to_hl, lnum)
    echohl Error
    echo 'No headline found at line ' . lnum
    echohl None
    return
  endif
  let hl = copy(b:to_hl[lnum])
  let hl.keyword = 'DONE'
  call hl.update()
  call s:rebuild_agenda(b:agenda_name)
endfunction

function! myorg#agenda_kwcycle(count) abort " {{{1
  if &filetype != 'agenda'
    throw 'Only usable in agenda filetypes'
  endif
  let lnum = line('.')
  if !has_key(b:to_hl, lnum)
    echohl Error
    echo 'No headline found at line ' . lnum
    echohl None
    return
  endif
  let hl = copy(b:to_hl[lnum])
  let keywords = org#outline#keywords(hl.filename)
  let keywords = [''] + keywords.all
  let hl.keyword = keywords[(index(keywords, hl.keyword) + a:count) % len(keywords)]

  call hl.update()
  call s:rebuild_agenda(b:agenda_name)
endfunction

function! myorg#agenda_plan(plan) abort " {{{1
  if &filetype != 'agenda'
    throw 'Only usable in agenda filetypes'
  endif
  let lnum = line('.')
  if !has_key(b:to_hl, lnum)
    echohl Error
    echo 'No headline found at line ' . lnum
    echohl None
    return
  endif
  let hl = copy(b:to_hl[lnum])
  let hl.plan = a:plan

  call hl.update()
  call s:rebuild_agenda(b:agenda_name)
endfunction

function! myorg#archive(discardTree) abort " {{{1
  let hl = org#outline#file(expand('%')).lnums[org#headline#at('.')]
  if !a:discardTree
    " TODO escapes & org#dir handling
    let name = split(hl.target, '\ze\V' . expand('%:t') . '/')[1]
  else
    let name = hl.target
  endif
  let name = name[: -len(hl.item) - 2]
  call org#refile('archive.org/' . name)
endfunction

function! myorg#dosnippet() abort " {{{1
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

  " The template + capture here will take care of proper header level, but will not shift
  " headlines in the snippet.
  let g:org#currentcapture.template = get(g:org#currentcapture, 'type', 'entry') == 'entry' ? '* snippet' : 'snippet'
  let g:org#currentcapture.snippet = "A\<C-r>=UltiSnips#Anon('" . snippet . "', 'snippet')\<Cr>"
  " let g:org#currentcapture.snippet = "A\<C-r>=UltiSnips#Anon(" . '"' . snippet . '"' . ", 'snippet')\<Cr>"
endfunction

function! myorg#processInboxItem(...) abort " {{{1
  let hl = exists('a:1') ? a:1 : org#headline#get('.')
  let hl = type(hl) == v:t_dict ? hl : org#headline#get(hl)
  if hl.keyword ==# 'PROJECT'  " {{{2
    if index(hl.tags, 'project') < 0
      let headline = input('Headline> ', hl.item)
      let tags = split(input("\n(Space separated)\nTags> ", 'project '))
      call org#headline#addtag('project')
    endif
    call org#keyword#set('')
    call org#headline#add(hl.level + 1, 'NEXT Add actionable items: ' . hl.text)
    call org#refile('todo.org')
  elseif hl.keyword ==# 'RECIPE'  " {{{2
    call org#keyword#set('NEXT')
    " Ingredients, tags, how do we want to structure the recipes?
    call org#refile('recipes.org')
  elseif hl.keyword ==# 'EVENT'  " {{{2
    call org#keyword#set('')
    if empty(org#plan#get('.'))
      let headline = input('Headline> ', hl.item)
      let time = input('Timestamp> ')
      call org#headline#set(headline)
      call org#plan#set(hl.lnum, {'TIMESTAMP': org#time#dict(time)})
    endif
    call org#refile('events.org')
  elseif hl.keyword ==# 'ACTIONABLE'  " {{{2
    " let targets = org#outline#file('todo.org')
    let targets = org#outline#file('todo.org', 1)
    let g:org#outline#complete#targets = filter(targets.list, 'index(v:val.tags, "project") >= 0')
    call map(g:org#outline#complete#targets, 'v:val.target')
    echo 'Processing:'
    echo hl.text
    let target = input('Refile to project> ', 'todo.org', 'customlist,org#outline#complete')
    call org#refile(target)
    call org#keyword#set('TODO')
    let tags = org#headline#gettags(org#headline#find('.', 1, 'nbW'))
    if index(tags, 'project') < 0
      call org#headline#settag(tags + ['project'])
    endif
  elseif hl.keyword ==# 'INACTIONABLE'  " {{{2
    " call s:add_actionable
    " Remove keyword
    " Add NEXT Add actionable items
    let targets = org#outline#file('todo.org')
    let g:org#outline#complete#targets = filter(targets.list, 'index(v:val.tags, "project") >= 0')
    call map(g:org#outline#complete#targets, 'v:val.target')
    echo 'Processing:'
    echo hl.text
    let target = input('Refile to project> ', 'todo.org', 'customlist,org#outline#complete')
    call org#headline#add(hl.level + 1, 'NEXT Add actionable items: ' . hl.text)
    call org#refile(target)
  elseif hl.keyword ==# 'SOMEDAY' || hl.keyword ==# 'MAYBE'  " {{{2
    call org#refile('later.org')
  elseif hl.keyword ==# 'NOTE'  " {{{2
    call org#refile('notebox.org')
  elseif hl.keyword ==# 'NEXT'  " {{{2
    call org#refile('todo.org/Do it do it do it')
  elseif hl.done ==# 'DONE'  " {{{2
    call org#refile('archive.org')
  endif " }}}
endfunction

function! myorg#process_repeats() abort " {{{1
  let tasks = org#agenda#filter(org#agenda#items(), 'TIMESTAMP+LATE')
  call filter(tasks, 'org#plan#repeats(v:val.plan)')

  let starttabnr = tabpagenr()
  for task in tasks
    let plan = {'TIMESTAMP': org#time#repeat(task.plan.TIMESTAMP)}
    " echo task.bufnr task.lnum + 1 org#plan#totext(plan)
    call setbufline(task.bufnr, task.lnum + 1, org#plan#totext(plan))
  endfor
  wall
endfunction

function! myorg#project_separator(hl) abort dict " {{{1
  if !has_key(self, 'lasttitle')
    " Get all projects without any items, and display those first
    let empty_projects = []
    let agenda = org#outline#multi(org#agenda#files())
    " Filter out the /files/ who have project as a tag
    call filter(agenda, 'index(v:val.tags, "project") >= 0')
    let self.titles = map(copy(agenda), 'get(v:val, "title", "NOTITLE")')
    for [name, prj] in items(agenda)
      if empty(org#agenda#filter(prj.list, 'project-DONE+KEYWORD'))
        call add(empty_projects, [prj.title, 'orgAgendaDate', {'filename': name, 'lnum': 1}])
      endif
    endfor

    let self.lasttitle = self.titles[a:hl.filename]
    return add(empty_projects, [self.titles[a:hl.filename], 'orgAgendaDate', {'filename': a:hl.filename, 'lnum': 1}])
  endif

  " Otherwise, display the current file for the project
  let title = self.titles[a:hl.filename]
  if self.lasttitle != title
    let self.lasttitle = title
    return [[title, 'orgAgendaDate', {'filename': a:hl.filename, 'lnum': 1}]]
  endif
  return []

endfunction

function! myorg#review() abort " {{{1
  let list = myorg#project_generator()
  let today = org#time#dict('today').start
  call filter(list, '!v:val.done && !s:plan_repeats(v:val) && !empty(v:val.keyword) && !org#plan#isplanned(v:val.plan, today)')
  for item in list
    let item.module = split(get(item.parent, "target", "/"), 'projects.org/')[-1]
  endfor
  call setqflist(list)
  tab new
  cfirst
  if empty(&filetype)
    setfiletype org
  endif
endfunction

function! myorg#new(title, refile) abort " {{{1
  if empty(a:title) && !a:refile
    echoerr 'If not refiling, then the title must not be empty'
    return
  endif
  let title = empty(a:title) && a:refile ? org#headline#get('.').item : a:title

  if a:refile
    " Find range of source and remove text we're filing
    let [st, end] = org#section#range('.')
    let text = getline(st, end)
    execute st . ',' . end . 'd _'
  endif

  execute 'new' s:reduce(title, 1)
  setfiletype org
  call setline(1, '#+TITLE: ' . title)

  if a:refile
    call append('$', [''] + text)
  endif
endfunction

function! s:reduce(text, prefix) abort " {{{2
  let text = substitute(a:text, '&', 'and', 'g')
  let text = substitute(text, '[^0-9A-Za-z_ \t]', '', 'g') " Non word & non space get removed
  let text = split(tolower(text))
  while len(text) > 0 && text[0] =~ '\v^(a|the)$'
    call remove(text, 0)
  endwhile
  let name =  join(text[:2], '_') . '.org'
  return !a:prefix ? name : sha256(strftime('%Y%m%d%H%M%S') . a:text)[:2] . '_' . name
endfunction

function! myorg#newproject(title, refile) abort range " {{{1
  if empty(a:title) && !a:refile
    echoerr 'If not refiling, then the title must not be empty'
    return
  endif
  let title = empty(a:title) && a:refile ? org#headline#get('.').item : a:title

  if a:refile
    " Find range of source and remove text we're filing
    let [st, end] = org#section#range('.')
    let text = getline(st, end)
    execute st . ',' . end . 'd _'
  endif

  execute 'new' s:reduce(title, 0)
  setfiletype org
  call setline(1, ['#+TITLE: ' . title, '#+FILETAGS: :project:'])

  if a:refile
    call append('$', [''] + text)
  endif
endfunction

function! s:rebuild_agenda(name) abort " {{{1
  let view = winsaveview()
  quit
  call org#agenda#build(a:name)
  call winrestview(view)
endfunction
