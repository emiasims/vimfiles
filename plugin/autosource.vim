function! s:setup_autosource() abort " {{{1
  augroup vimrc_autosource
    autocmd!
    autocmd BufWritePost autoload/*.vim,plugin/*.vim,indent/*.vim,lua/*.lua ++nested source % | echo 'Sourced ' . expand('%')
  augroup END
  echom 'Autosource set up on files matching: {autoload,plugin,indent}/*.vim, and lua/*.lua'
endfunction

command! AutoSourceEnable call s:setup_autosource()
command! AutoSourceDisable autocmd! vimrc_autosource
