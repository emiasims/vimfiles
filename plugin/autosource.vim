function! s:setup_autosource() abort " {{{1
  augroup vimrc_autosource
    autocmd!
    autocmd BufWritePost autoload/*.vim source % | echo 'Sourced ' . expand('%')
  augroup END
endfunction

command! AutoSourceEnable call s:setup_autosource()
command! AutoSourceDisable autocmd! vimrc_autosource
