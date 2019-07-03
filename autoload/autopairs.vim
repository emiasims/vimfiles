let s:pairs = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'"}
let s:end_pairs = {')': '(', ']': '[', '}': '{', '"': '"', "'": "'"}

function! s:nextchar() abort
  return strpart(getline('.'), col('.')-1, 1)
endfunction

function! s:prevchar() abort
  return strpart(getline('.'), col('.')-2, 1)
endfunction

function! autopairs#backspace() abort
  let l:prev = s:prevchar()
  if has_key(s:pairs, l:prev) && s:pairs[l:prev] ==# s:nextchar()
    return "\<BS>\<DEL>"
  endif
  return "\<BS>"
endfunction

function! s:completing_pair(char) abort
  if has_key(s:end_pairs, a:char) && !(index(get(b:, 'autopairs_skip', []), a:char) >= 0)
    return a:char ==# s:nextchar()
  endif
  return 0
endfunction

function! s:is_pair(char) abort
  if has_key(s:pairs, a:char) && !(index(get(b:, 'autopairs_skip', []), a:char) >= 0)
    return s:nextchar() !~? '\w' && ((a:char !=# get(s:pairs, a:char, '')) || (s:prevchar() !~? '\w'))
  endif
  return 0
endfunction

function! autopairs#check_and_insert(char) abort
  if s:completing_pair(a:char)
    return "\<C-g>U\<right>"
  elseif s:is_pair(a:char)
    return a:char . s:pairs[a:char] . "\<C-g>U\<left>"
  endif
  return a:char
endfunction
