" File: smooth.vim
" Author: Matt Simmons <matt.simmons at compbiol.org>
" License: MIT license

scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

" Defaults
let g:smooth_interval = exists('g:smooth_interval') ? g:smooth_interval : 16
let g:smooth_minimum = exists('g:smooth_minimum') ? g:smooth_minimum : 10

if !exists('g:Smooth#speed')
  function s:speed(y)
    return 58 + 2*a:y + 50*tanh((a:y-10)/5)
  endfunction

  let g:Smooth#speed = function('s:speed')
endif

function! s:scroll_handler(timer) abort
  if s:remaining <= 0
    call smooth#reset()
    return
  endif

  " calculate dy ...
  let l:speed = g:Smooth#speed(s:remaining + s:dy)

  if l:speed <= g:smooth_minimum
    if g:smooth_minimum <= 0
      let g:smooth_minimum = 10
    endif
    let l:speed = g:smooth_minimum
  endif

  let s:dy += l:speed * reltimefloat(reltime(s:relt))
  let s:relt = reltime()
  let l:dy_step = float2nr(floor(s:dy))
  if l:dy_step <= 0
    return
  endif
  let s:dy -= l:dy_step
  let s:remaining -= l:dy_step

  " scroll ...
  let l:cmd = 'normal! '
  if !s:scroll_with_cursor || !(line('$') == line('w$')) || (s:direction < 0)
    let l:cmd .= string(l:dy_step) . (s:direction > 0 ? "\<C-e>" : "\<C-y>")
  endif
  if s:scroll_with_cursor
    let l:cmd .= string(l:dy_step) . (s:direction > 0 ? 'gj' : 'gk')
  endif
  execute l:cmd
  redraw
endfunction

function! smooth#reset() abort
  let s:dy = 0.0
  let s:remaining = 0
  let s:direction = 0
  let s:scroll_with_cursor = 0

  if has('timers') && exists('s:timer_id')
    call timer_stop(s:timer_id)
    unlet s:timer_id
  endif
endfunction

function! smooth#scroll(distance, scroll_with_cursor) abort
  let s:scroll_with_cursor = a:scroll_with_cursor
  if !s:scroll_with_cursor
    call smooth#reset()
  endif
  let s:remaining = s:direction * s:remaining + float2nr(a:distance)
  let s:direction = s:remaining > 0 ? 1 : -1
  let s:remaining = abs(s:remaining)
  let s:relt = reltime()
  if s:scroll_with_cursor && (s:direction < 0) && (s:remaining > line('.'))
    let s:remaining = line('.')
  endif
  if s:scroll_with_cursor && (s:direction > 0) && (s:remaining > line('$') - line('.'))
    let s:remaining = line('$') - line('.')
  endif

  let l:interval = float2nr(round(g:smooth_interval))
  if !has('timers')
    while s:remaining > 0
      let s:timer_id = 1
      call s:scroll_handler(s:timer_id)
      execute 'sleep '.l:interval.'m'
    endwhile
  elseif !exists("s:timer_id")
    let s:timer_id = timer_start(l:interval, function("s:scroll_handler"), {'repeat': -1})
  endif
endfunction

call smooth#reset()
augroup vimrc_smooth
  autocmd!
  autocmd WinEnter,WinLeave * call smooth#reset()
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=2 sw=2 tw=99 et :
