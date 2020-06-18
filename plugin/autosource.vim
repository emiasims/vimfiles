function! s:setup_autosource(...) abort " {{{1
  " for use with <q-args>
  let pattern = empty(a:000) ? 'autoload/*.vim' : join(map(copy(a:000), 'v:val . ''*.vim''  '), ',')
  augroup vimrc_autosource
    autocmd!
    execute "autocmd BufWritePost" pattern "source % | echo 'Sourced ' . expand('%')"
  augroup END
  echom 'Autosource set up on files matching:' pattern
endfunction

command! -nargs=* AutoSourceEnable call s:setup_autosource(<f-args>)
command! AutoSourceDisable autocmd! vimrc_autosource
