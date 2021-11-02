if !has('nvim')
  finish
endif

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
  let g:org#currentcapture.template = get(g:org#currentcapture, 'type', 'entry') == 'entry' ? "* snippet" : 'snippet'
  let g:org#currentcapture.snippet = "A\<C-r>=UltiSnips#Anon('" . snippet . "', 'snippet')\<Cr>"
  " let g:org#currentcapture.snippet = "A\<C-r>=UltiSnips#Anon(" . '"' . snippet . '"' . ", 'snippet')\<Cr>"
endfunction

function! myorg#updateTasks(...) abort " {{{1
  let day = org#time#dict(get(a:, 1, localtime() - 3600 * 3))
  let target = org#headline#fromtarget(s:journaltarget(day)..'/Tasks', 1)
  let range = s:getrange(target)

  if range[1] - range[0] <= 3
    " From #makeplan
    let routine = readfile(org#dir() . '/daily_routine.org')[1:] + ['', '']
    call appendbufline(target.bufnr, prevnonblank(range[1]), routine)
    let range = s:getrange(target)
  endif

  " Get items that have TODO headlines attached
  let current = {}
  for ln in getbufline(target.bufnr, range[0] + 1, range[1])
    let parts = matchlist(ln, '\v^\s*- \[(.)\] \[\[([^\]]*)\]\[[^\]]*\]\]')
    if len(parts)
      let current[parts[2]] = parts[1] =~? 'x'
    endif
  endfor

  let items = filter(org#agenda#items(), org#agenda#filter('KEYWORD-MEETING-WAITING+PLAN<='..day.start))
  call map(items, "extend(v:val, {'link': s:tolink(v:val, 0)})")
  call filter(items, "!has_key(current, v:val.link)")
  call map(items, "extend(v:val, {'link': s:tolink(v:val, 1)})")
  call map(items, "printf('  - [ ] %s', v:val.link)")
  call appendbufline(target.bufnr, range[1] - 1, items)

  if !exists('a:1')
    return
  endif

  " let range[1] += len(items)
  " let ix = match(getbufline(target.bufnr, range[0], range[1]), '\V'..s:tolink(copy(a:1), 0))
  " if ix >= 0
  "   call setbufline(target.bufnr, range[0], )
  " else
  " endif

endfunction

function! s:getrange(target) abort " {{{1
  let lines = getbufline(a:target.bufnr, 1, '$')
  let endl = match(lines, '^\*', a:target.lnum + 1)
  if endl == a:target.lnum + 1
    let endl -= 1
  elseif endl < 0
    let endl = len(lines)
  endif
  return [a:target.lnum, endl]
endfunction

function! myorg#generateid(headline, ...) abort " {{{1
  " Why? Because I like how it looks.
  let id = sha256(strftime('%Y%m%d%H%M', get(a:, 1, localtime())) . a:headline)
  let prefix = join(map(split(a:headline)[:6], 'matchstr(v:val, "[[:alnum:]]")'), '')
  return prefix . '-' . id[: 12 - len(prefix)]
endfunction

function! myorg#completeTaskInJournal() abort " {{{1
  let hl = org#headline#get('.')
  let hl.done = 1
  update " simplify awkward caching problems
  call myorg#updateTasks(localtime() - 3600 * 3, hl)
endfunction

function! s:journaltarget(...) abort " {{{1
  let t = exists('a:1') ? org#time#dict(a:1).start : localtime() - 3600 * 3
  let date = str2nr(strftime('%d', t))  " str2nr removes prefix 0
  let target = 'diary.org/' . strftime('%B/%A the ', t) . str2nr(strftime('%d', t))
  if date  =~ '1[123]'
    let target .= 'th'
  else
    let target .= get({1: 'st', 2: 'nd', 3: 'rd'}, date % 10, 'th')
  endif
  return target
endfunction


function! myorg#process_repeats() abort " {{{1
  let tasks = filter(org#agenda#items(), org#agenda#filter('TIMESTAMP+LATE'))
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
    let flt = org#agenda#filter('project-DONE+KEYWORD')
    for [name, prj] in items(agenda)
      if empty(filter(prj.list, flt))
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

function! myorg#capturewindow(templates) abort " {{{1
  let templates = map(copy(a:templates), {_, t -> [t.key, t.description]})
  " let templates = map(templates, {_, t -> [t[0], type(t[1]) == v:t_func ? t[1]() : t[1]]})
  let fulltext = s:capture_text(templates)
  let winid = has('nvim') ? s:nvimwin(fulltext) : s:vimwin(fulltext)
  let selection = ''
  messages clear

  while 1
    redraw
    try
      let capture = getchar()
    catch /^Vim:Interrupt$/  " for <C-c>
      call s:closewin(winid) | return {}
    endtry
    if capture == char2nr("\<Esc>")
      call s:closewin(winid) | return {}
    elseif capture == char2nr("\<Cr>") && !empty(selection)
      break
    endif
    let selection = selection . nr2char(capture)
    let reduced = filter(copy(templates), {_, t -> t[0][: len(selection) - 1] == selection})
    if len(reduced) == 1
      break
    elseif len(reduced) == 0
      call s:set_text(winid, fulltext)
      let selection = ''
    elseif len(reduced) > 1
      call s:set_text(winid, s:capture_text(reduced, fulltext))
    endif
  endwhile

  call s:closewin(winid)
  return filter(copy(a:templates), 'v:val.key == selection')[0]
endfunction

function! s:capture_text(options, ...) abort " {{{2
  let full = get(a:, 1, a:options)
  let text = map(copy(a:options), {_, t -> '  ' . t[0] . repeat(' ', 5 - len(t[0])) . t[1]})
  return text + map(range(len(full) - len(text)), '""')
endfunction

function! s:closewin(winid) abort " {{{2
  if has('nvim') | quit | else | call popup_close(a:winid) | endif
endfunction

function! s:getlines() abort " {{{2
  " Get 'absolute' line number. Seems easier than traversing winlayout()
  let [start, lines] = [winnr(), winline() + 1]
  noautocmd wincmd k
  while winnr() != winnr('k')
    let lines += winheight(winnr()) + 1
    noautocmd wincmd k
  endwhile
  return lines
endfunction

function! s:nvimwin(text) abort " {{{2
  let buf = nvim_create_buf(v:false, v:true)
  let s:buf = buf
  let above = (s:getlines() + len(a:text) + 3 > &lines)
  let opts = {
        \ 'relative': 'cursor',
        \ 'row': !above,
        \ 'col': -1,
        \ 'width': 3 + max(map(copy(a:text), 'len(v:val)')),
        \ 'height': len(a:text) + 1,
        \ 'anchor': above ? "SW" : "NW",
        \ }

  let winid = nvim_open_win(buf, v:true, opts)
  setfiletype org-capture
  call setline(1, ' Capture:')
  call append('$', a:text)
  return winid
endfunction

function! s:set_text(winid, text) abort " {{{2
  if has('nvim')
    call setline(1, ' Capture:')
    call setline(2, a:text)
  else
    call win_execute(a:winid, 'call setline(1, " Capture:")')
    call win_execute(a:winid, 'call setline(2, a:text)')
  endif
endfunction

function! s:vimwin(text) abort " {{{2
  let text = [' Capture:'] + a:text
  let above = (s:getlines() + len(a:text) + 1 > &lines)
  let winid = popup_atcursor(text, {
        \ 'pos': above ? 'botleft' : 'topleft',
        \ 'col': above ? 'cursor' : 'cursor-1',
        \ 'minwidth': 3 + max(map(copy(a:text), 'len(v:val)')),
        \ })
  call win_execute(winid, 'setfiletype org-capture')
  return winid
endfunction

function! myorg#capture() range abort " {{{1
  if type(g:org#capture#templates) == v:t_dict
    let order = copy(get(g:, 'org#capture#order', sort(keys(g:org#capture#templates))))
    let order = filter(order, 'has_key(g:org#capture#templates, v:val)')
    let templates = map(order, {_, k -> extend(g:org#capture#templates[k], {'key': k})})
  elseif type(g:org#capture#templates) == v:t_list
    let templates = copy(g:org#capture#templates)
  endif

  let templates = filter(templates, {_, t -> !has_key(t, 'context') || (type(t.context) == 1 ? eval(t.context) : t.context())})
  let capture = myorg#capturewindow(templates)
  if empty(capture) | return | endif
  call org#capture#do(capture)
endfunction

function! myorg#makeplan(...) abort " {{{1
  let day = get(a:, 1, localtime() - 3600 * 3 + 86400)
  let target = org#headline#fromtarget(s:journaltarget(day) .. '/Tasks', 1)
  let range = s:getrange(target)
  if range[1] - range[0] > 3
    call s:displaydiary(range[0] + 2)
    return
  endif

  let routine = readfile(org#dir() . '/daily_routine.org')[1:] + ['', '']
  call appendbufline(target.bufnr, prevnonblank(range[1]), routine)
  call myorg#updateTasks(day)
  call s:displaydiary(range[0] + 2)

  " let items = myorg#get_agendatasks()
  " call map(items, "extend(v:val, {'link': s:tolink(v:val, 1)})")
  " call map(items, "printf('  - [ ] %s', v:val.link)")
  " let items = readfile(org#dir() . '/daily_routine.org')[1:] + [''] + items + ['']
  " call appendbufline(target.bufnr, prevnonblank(range[1]), items)
  " call s:displaydiary(range[0] + 2)

endfunction

function! s:displaydiary(lnum) abort " {{{1
  execute 'tabe +' . a:lnum org#dir() . '/diary.org'
  redraw!
  " call cursor(range[0] + 2, 3)
  normal! zMzv
  redraw!
  let g:last_agenda='planning'
  call org#agenda#build('planning')
endfunction

" function! myorg#write_new(target, items) abort " {{{1
" endfunction

function! s:tolink(hl, fulltext) abort " {{{1
  if a:fulltext
    return printf('[[file:%s::*%s][%s]]', fnamemodify(a:hl.filename, ':t'), a:hl.item, a:hl.item)
  endif
  return printf('file:%s::*%s', fnamemodify(a:hl.filename, ':t'), a:hl.item)
endfunction
