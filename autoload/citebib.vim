if has('python3')
  try
    python3 import citebib
  catch
    echoerr 'citebib could not be imported.'
    finish
  endtry
else
  echoerr 'Python3 unsupported for citebib.'
  finish
endif

let g:loaded_citebib = 1

" TODO: viml bibtex parser. should just be able to use regex.

function! citebib#reset() abort " {{{1
  let s:bib = {}  " gitdir: {filename: [modtime, [bibitem... bibitem...]], filename: [...]}
  let s:bib_cache = {}  " gitdir: [concat bibitems]
  let s:update_cache = {}  " gitdir: 1 or 0
  " See: escape codes
  let s:col = {'black': "\<Esc>[30m",
        \ 'red': "\<Esc>[31m",
        \ 'green': "\<Esc>[32m",
        \ 'yellow': "\<Esc>[33m",
        \ 'blue': "\<Esc>[34m",
        \ 'magenta': "\<Esc>[35m",
        \ 'cyan': "\<Esc>[36m",
        \ 'white': "\<Esc>[37m"}
  let s:bold = {'black': "\<Esc>[30;1m",
        \ 'red': "\<Esc>[31;1m",
        \ 'green': "\<Esc>[32;1m",
        \ 'yellow': "\<Esc>[33;1m",
        \ 'blue': "\<Esc>[34;1m",
        \ 'magenta': "\<Esc>[35;1m",
        \ 'cyan': "\<Esc>[36;1m",
        \ 'white': "\<Esc>[37;1m"}
  let s:reset = "\<Esc>[0m"
  " See citebib.py for order of entries.
  " let s:nodes = ['entrytype', 'author', 'journal', 'year', 'title', 'id']
  let s:colors = [s:col['yellow'], s:bold['blue'], s:bold['yellow'],
        \ s:col['magenta'], s:col['white'], s:bold['green']]
endfunction
call citebib#reset()

function! s:get_list(fname) abort " {{{1
  silent execute 'python3 citebib.parse_bibtex("' . a:fname . '")'
  return l:return
endfunction

function! s:parse(fname) abort " {{{1
  let s:update_cache[getcwd()] = 1
  let s:bib[getcwd()][a:fname] = [getftime(a:fname), s:get_list(a:fname)]
endfunction

function! s:find_bibfiles() " {{{1
  if !has_key(s:bib, getcwd())
    let s:bib[getcwd()] = {}
  endif
  let l:findout = globpath('.', '**/*.bib')
  for l:f in split(l:findout, '\n')
    if filereadable(l:f)
      let l:f = fnamemodify(l:f, ':p')
      if !has_key(s:bib[getcwd()], l:f)
        let s:bib[getcwd()][l:f] = [-1, []]
      endif
    endif
  endfor
endfunction

function! s:check_modtimes_and_parse() abort " {{{1
  for l:file in keys(s:bib[getcwd()])
    if getftime(l:file) > s:bib[getcwd()][l:file][0]
      call s:parse(l:file)
    endif
  endfor
endfunction

function! s:colorize(bibindex, bibentry) abort " {{{1
  let l:index = 0
  while l:index < len(a:bibentry)
    let a:bibentry[l:index] = s:colors[l:index] . a:bibentry[l:index] . s:reset
    let l:index += 1
  endwhile
  return join(a:bibentry, ' ')
endfunction

function! s:check_cache() abort " {{{1
  " update data in cache
  if s:update_cache[getcwd()]
    let s:bib_cache[getcwd()] = []
    for l:bib_file in keys(s:bib[getcwd()])
      call extend(s:bib_cache[getcwd()], s:bib[getcwd()][l:bib_file][1])
    endfor
    call map(s:bib_cache[getcwd()], funcref('s:colorize'))
    let s:update_cache[getcwd()] = 0
  endif
endfunction

function! s:reducer(lines) abort " {{{1
  return join(a:lines)
  " call map(a:lines, {i, x -> split(x, ' ')[-1][1:-2]})
  " return '[@' . join(a:lines, '] [@') . ']'
endfunction

function! s:run_fzf() abort " {{{1
  let l:opts = { 'source': s:bib_cache[getcwd()],
        \ 'reducer': funcref('s:reducer'),
        \ 'options': ['--ansi', '--multi', '--prompt=Cite> '] }
  return fzf#vim#complete(fzf#wrap('citations', l:opts))
endfunction

function! citebib#fzf() abort " {{{1
  call s:find_bibfiles()
  call s:check_modtimes_and_parse()
  call s:check_cache()
  return s:run_fzf()
endfunction
