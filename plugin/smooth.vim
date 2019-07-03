" Author: Matt Simmons <matt.simmons at compbiol.org>
" License: MIT license

scriptencoding utf-8

if exists('g:loaded_smooth')
  finish
endif
if !has('patch-7.4.1285') && !has('nvim')
  finish
endif
let g:loaded_smooth = 1

let s:save_cpo = &cpo
set cpo&vim

nnoremap <silent> <Plug>(SmoothUp)        :call smooth#scroll(-&scroll, 1)<CR>
nnoremap <silent> <Plug>(SmoothDown)      :call smooth#scroll(&scroll, 1)<CR>
nnoremap <silent> <Plug>(SmoothPageUp)    :call smooth#scroll(-&scroll * 2, 0)<CR>
nnoremap <silent> <Plug>(SmoothPageDown)  :call smooth#scroll(&scroll * 2, 0)<CR>
nnoremap <silent> <Plug>(Smooth_zCR)     ^:<C-u>call smooth#scroll(winline() - &scrolloff, 0)<CR>
nnoremap <silent> <Plug>(Smooth_zt)       :<C-u>call smooth#scroll(winline() - &scrolloff - 1, 0)<CR>
nnoremap <silent> <Plug>(Smooth_z.)      ^:<C-u>call smooth#scroll(winline() - winheight(0)/2, 0)<CR>
nnoremap <silent> <Plug>(Smooth_zz)       :<C-u>call smooth#scroll(winline() - winheight(0)/2, 0)<CR>
nnoremap <silent> <Plug>(Smooth_z-)      ^:<C-u>call smooth#scroll(winline() - winheight(0) + &scrolloff, 0)<CR>
nnoremap <silent> <Plug>(Smooth_zb)       :<C-u>call smooth#scroll(winline() - winheight(0) + &scrolloff, 0)<CR>
nnoremap <silent> <Plug>(SmoothC-e)       :<C-u>call smooth#scroll(v:count1, 0)<CR>
nnoremap <silent> <Plug>(SmoothC-y)       :<C-u>call smooth#scroll(- v:count1, 0)<CR>
nnoremap <silent> <Plug>(SmoothTop)       :<C-u>call smooth#scroll(-line('.'), 1)<CR>
nnoremap <silent> <Plug>(SmoothBottom)    :<C-u>call smooth#scroll(line('$') - line('.'), 1)<CR>


if !exists('g:smooth_bindings')
  let g:smooth_bindings = {
        \  '<C-u>' : '<Plug>(SmoothUp)',
        \  '<C-d>' : '<Plug>(SmoothDown)',
        \  '<C-b>' : '<Plug>(SmoothPageUp)',
        \  '<C-f>' : '<Plug>(SmoothPageDown)',
        \  'z<CR>' : '<Plug>(Smooth_zCR)',
        \  'zt'    : '<Plug>(Smooth_zt)',
        \  'z.'    : '<Plug>(Smooth_z.)',
        \  'zz'    : '<Plug>(Smooth_zz)',
        \  'z-'    : '<Plug>(Smooth_z-)',
        \  'zb'    : '<Plug>(Smooth_zb)',
        \  '<C-e>' : '<Plug>(SmoothC-e)',
        \  '<C-y>' : '<Plug>(SmoothC-y)',
        \  'gg'    : '<Plug>(SmoothTop)',
        \  'G'     : '<Plug>(SmoothBottom)'
        \ }
endif

function! s:bind() abort
    for s:bind in keys(g:smooth_bindings)
      if !hasmapto(g:smooth_bindings[s:bind]) && maparg(s:bind, 'n') ==# ''
        execute	'nmap ' . s:bind . ' ' . g:smooth_bindings[s:bind]
      endif
    endfor
endfunction

function! s:unbind() abort
  for s:bind in keys(g:smooth_bindings)
      if maparg(s:bind, 'n') ==# g:smooth_bindings[s:bind]
        execute 'nunmap ' . s:bind
      endif
  endfor
endfunction

command! -nargs=0 SmoothEnable call smooth#reset() | call s:bind()
command! -nargs=0 SmoothDisable call s:unbind()

let &cpo = s:save_cpo
unlet s:save_cpo
