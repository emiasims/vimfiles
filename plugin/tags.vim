function! tags#smartedit(text) abort " {{{1
  " Should be like <C-]>, but use smartsplit
  let tags = taglist(a:text)
  if len(tags) == 1
    execute 'JumpOrEdit' tags[0].filename
    silent execute tags[0].cmd
  elseif len(tags) > 1
    let s:tags = tags
    let tags = map(copy(s:tags), {i, t -> i . ': ' . t.name . "\t" . fnamemodify(t.filename, ':~:.')})
    call fzf#run(fzf#wrap({'source': tags, 'sink': funcref('s:fzf_sink')}))
  else
    echoerr 'No tags found'
  endif
endfunction

function! s:fzf_sink(selection) abort " {{{2
  let tag = s:tags[split(a:selection, ':')[0]]
  execute 'JumpOrEdit' tag.filename
  silent execute tag.cmd
  unlet s:tags
endfunction

nnoremap <C-]> :<C-u>call tags#smartedit(expand('<cword>'))<Cr>
