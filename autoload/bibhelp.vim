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

let g:bibhelp#cache = {}

function! bibhelp#update_summaryfile(...) abort " {{{1

  let summaryfile = get(g:, 'bibhelp#orgfile', '~/org/literature/read.org')
  call org#agenda#file_cache(summaryfile)  " only helps if it's in agenda files
  let dois = map(filter(org#agenda#list(summaryfile), 'v:val.LEVEL == 1'), 'v:val.doi')

  let startbufnr = bufnr()
  execute 'JumpOrEdit' summaryfile

  for fname in map(copy(a:000), 'resolve(fnamemodify(v:val, ":p"))')
    if !has_key(g:bibhelp#cache, fname) || getftime(fname) > g:bibhelp#cache[fname].mtime
      let g:bibhelp#cache[fname] = {'mtime': getftime(fname)}
      for entry in bibhelp#parsebib(fname)
        if index(dois, entry.doi) == -1
          call bibhelp#add_entry(entry, ['Intro & Notes', 'Findings'])
          call add(dois, entry.doi)
        endif
      endfor
    endif
  endfor
endfunction

function! bibhelp#parsebib(fname) abort " {{{1
python3 << EOF
import bibtexparser, vim
with open(vim.eval('a:fname')) as bf:
    parser = bibtexparser.bparser.BibTexParser(common_strings=True)
    bd = bibtexparser.load(bf, parser=parser)
    vim.command('let l:return = {}'.format(str(bd.entries)))
EOF
  let count = 0
  for entry in l:return
    let entry['bibfile'] = a:fname
    let entry['index'] = count
    let count += 1
  endfor
  return l:return
endfunction

function! s:parse_authors(authors) abort " {{{1
  let author_list = []
  for author in split(a:authors, ' and ')
    let [last, first] = split(author, ', ')
    call add(author_list, first . ' ' . last)
  endfor
  return len(author_list) > 0 ? author_list : ['Unknown']
endfunction

function! bibhelp#add_entry(entry, sections) abort " {{{1

  let author_list = s:parse_authors(get(a:entry, 'author', ''))
  for candidate in split(get(a:entry, 'file', ''), ';')
    if candidate =~? '\.pdf$' && filereadable(fnameescape(candidate))
      let l:filename = candidate
      break
    endif
  endfor

  if !empty(getline(line('$')))
    call append(line('$'), '')
  endif
  call org#headline#add(line('$'), 1, 'UNREAD ' . s:cleanUp(get(a:entry, 'title', 'No title')))

  for au in author_list
    call org#property#add(line('$'), 'author+', au)
  endfor
  call org#property#add(line('$'), 'year', split(get(a:entry, 'date', 'Unknown'), '-')[0])
  call org#property#add(line('$'), 'journal', get(a:entry, 'journaltitle', 'Unknown'))
  call org#property#add(line('$'), 'doi', get(a:entry, 'doi', 'Unknown'))
  call org#property#add(line('$'), 'url', get(a:entry, 'url', 'Unknown'))
  call org#property#add(line('$'), 'date-added', strftime("%Y-%m-%d %a %H:%M"))
  call org#property#add(line('$'), 'file', get(l:, 'filename', 'None'))
  call org#property#add(line('$'), 'bibfile', get(a:entry, 'bibfile', ''))
  call org#property#add(line('$'), 'bibtex', get(a:entry, 'ID', 'Unknown'))

  for sname in a:sections
    call append(line('$'), [''])
    call org#headline#add(line('$'), 2, sname)
  endfor
endfunction

function! bibhelp#make_review(fname) abort " {{{1
  let fname = empty(a:fname) ? expand('%') : a:fname
  if !filereadable(fname)
    echoerr "File:" fname "not readable."
    return
  endif

  let lines = []
  for entry in bibhelp#parsebib(fname)
    let info = '### ' . s:cleanUp(entry.journaltitle) . ' - ' . get(entry, 'date', 'date?') . ';  '
    if has_key(entry, 'doi')
      let info .= '[doi: ' . entry.doi . '](https://doi.org/' . entry.doi . ')'
    endif
    if has_key(entry, 'url')
      let info .= ' ;  [online-link](' . entry.url . ')'
    endif
    " \ '### ' . s:cleanUp(entry.journaltitle) . ' - ' . entry.date . ';   . ' ;  url: ' . entry.url,
    call extend(lines, [
          \ info,
          \ '## ' . s:cleanUp(entry.title),
          \ '#### ' . join(s:parse_authors(get(entry, 'author', '')), ', '),
          \ '',
          \ s:cleanUp(entry.abstract),
          \ '', '',
          \ ])
  endfor

  let prefix = matchstr(fname, '.*\ze\.bib')
  execute 'SmartSplit'  prefix . '.md'
  call append(0, lines[:-3])  " don't want the last 2 lines
  write
  execute '!pandoc "%" --reference-doc="$HOME/mnt/WinMBox/custom-reference.docx" -o' prefix . '.docx > /dev/null 2>&1'
  bdelete
  call delete(prefix . '.md')
  echo 'Wrote' prefix . '.docx'
endfunction

function! s:cleanUp(text) abort " {{{1
  let text = substitute(a:text, '[}{]', '', 'g')
  let text = substitute(text, '\\n', ' ', 'g')
  return text
endfunction
