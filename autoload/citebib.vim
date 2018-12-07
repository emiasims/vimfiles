scriptencoding utf-8

if exists('g:loaded_citebib')
  finish
endif

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

function! citebib#reset() abort
  let s:bib = {}  " gitdir: {filename: [modtime, [bibitem... bibitem...]], ...}
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

function! s:get_list(fname) abort
  silent execute 'python3 citebib.parse_bibtex("' . a:fname . '")'
  return l:return
endfunction

function! s:parse(fname) abort
  let s:update_cache[b:git_dir] = 1
  let s:bib[b:git_dir][a:fname] = [getftime(a:fname), s:get_list(a:fname)]
endfunction

function! s:find_bibfiles()
  if !has_key(s:bib, b:git_dir)
    let s:bib[b:git_dir] = {}
  endif
  redir => l:findout
  silent execute "!find -maxdepth 4 -iname '*.bib'"
  redir END
  for l:f in split(l:findout, '\n')
    if filereadable(l:f)
      let l:f = fnamemodify(l:f, ':p')
      if !has_key(s:bib[b:git_dir], l:f)
        let s:bib[b:git_dir][l:f] = [-1, []]
      endif
    endif
  endfor
endfunction

function! s:check_modtimes_and_parse() abort
  for l:file in keys(s:bib[b:git_dir])
    if getftime(l:file) > s:bib[b:git_dir][l:file][0]
      call s:parse(l:file)
    endif
  endfor
endfunction

function! s:colorize(bibindex, bibentry) abort
  let l:index = 0
  while l:index < len(a:bibentry)
    let a:bibentry[l:index] = s:colors[l:index] . a:bibentry[l:index] . s:reset
    let l:index += 1
  endwhile
  return join(a:bibentry, ' ')
endfunction

function! s:check_cache() abort
  " update data in cache
  if s:update_cache[b:git_dir]
    let s:bib_cache[b:git_dir] = []
    for l:bib_file in keys(s:bib[b:git_dir])
      call extend(s:bib_cache[b:git_dir], s:bib[b:git_dir][l:bib_file][1])
    endfor
    call map(s:bib_cache[b:git_dir], funcref('s:colorize'))
    let s:update_cache[b:git_dir] = 0
  endif
endfunction

function! s:reducer(lines) abort
  call map(a:lines, {i, x -> split(x, ' ')[-1][1:-2]})
  return '[@' . join(a:lines, '][@') . ']'
endfunction

function! s:run_fzf() abort
  let l:opts = { 'source': s:bib_cache[b:git_dir],
        \ 'reducer': funcref('s:reducer'),
        \ 'options': ['--ansi', '--multi', '--prompt=Cite> '] }
  return fzf#vim#complete(fzf#wrap('citations', l:opts))
endfunction

function! citebib#fzf() abort
  if !exists('b:git_dir')
    echoerr 'No git dir found.'
    return
  endif
  call s:find_bibfiles()
  call s:check_modtimes_and_parse()
  call s:check_cache()
  echom s:bib_cache[b:git_dir][0]
  return s:run_fzf()
endfunction
