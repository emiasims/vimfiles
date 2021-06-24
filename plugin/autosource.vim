function! s:setup_autosource() abort " {{{1
  augroup vimrc_autosource
    autocmd!
    autocmd BufWritePost autoload/*.vim,plugin/*.vim,indent/*.vim source % | echo 'Sourced ' . expand('%')
    " TODO Use SourceCmd event to reload lua files.
    if has('nvim')
      autocmd BufWritePost lua/*.lua call v:lua.reload(join(split(expand('<afile>'), '/')[1:], '.')[:-5])
    endif
  augroup END
  echom 'Autosource set up on files matching: {autoload,plugin,indent}/*.vim, and lua/*.lua'
endfunction

command! AutoSourceEnable call s:setup_autosource()
command! AutoSourceDisable autocmd! vimrc_autosource
