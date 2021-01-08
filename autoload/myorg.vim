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
  let g:org#currentcapture.template = g:org#currentcapture.type == 'entry' ? '* snippet' : 'snippet'
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
  let task = filter(org#outline#file('ongoing.org').list, 'org#plan#islate(v:val.plan) && org#plan#repeats(v:val.plan)')

  let starttabnr = tabpagenr()
  noautocmd $tab split ~/org/ongoing.org
  try
    for event in events
      let plan = {'TIMESTAMP': org#time#repeat(event.plan.TIMESTAMP)}
      call setline(event.lnum + 1, org#plan#totext(plan))
    endfor
    update
  finally
    quit
    execute 'noautocmd normal!' starttabnr . 'gt'
  endtry
endfunction

function! myorg#project_filter(hl) abort " {{{1
  " if empty(a:hl.plan) || a:hl.done || empty(a:hl.keyword)
  if a:hl.done || empty(a:hl.keyword)
    return 0
  endif
  let parent = a:hl.parent
  let inproject = index(a:hl.tags, "project") >= 0
  while !empty(parent) && !inproject
    let inproject = index(parent.tags, "project") >= 0
    let parent = parent.parent
  endwhile
  return inproject
endfunction

function! myorg#project_generator() abort " {{{1
  let items = org#outline#file('todo.org').list
  let target2item = {org#util#fname('todo.org'): {}}
  for item in items
    let target2item[item.target] = item
  endfor
  for item in items
    let item.parent = target2item[substitute(item.target, '/[^/]*$', '', '')]
  endfor
  return items
endfunction

function! myorg#project_separator(hl) abort dict " {{{1
  if empty(self.cache)
    let self.cache.projects = filter(org#outline#file('todo.org').list, 'index(v:val.tags, "project") >= 0')
  endif
  let sections = []
  while a:hl.lnum > self.cache.projects[0].lnum
    let pr = remove(self.cache.projects, 0)
    call add(sections, [pr.item, 'orgAgendaDate'])
  endwhile
  return sections
endfunction

function! myorg#review() abort " {{{1
  let list = myorg#project_generator()
  let today = org#time#dict('today').start
  call filter(list, '!v:val.done && !s:plan_repeats(v:val) && !empty(v:val.keyword) && !org#plan#isplanned(v:val.plan, today)')
  for item in list
    let item.module = split(get(item.parent, "target", "/"), 'todo.org/')[-1]
  endfor
  call setqflist(list)
  tab new
  cfirst
  if empty(&filetype)
    setfiletype org
  endif
endfunction

function! s:rebuild_agenda(name) abort " {{{1
  let view = winsaveview()
  quit
  call org#agenda#build(a:name)
  call winrestview(view)
endfunction
