function! s:setup_autosource(...) abort " {{{1
  " for use with <q-args>
  " let pattern = empty(a:000) ? 'autoload/*.vim' : join(map(copy(a:000), 'v:val . ''*.vim''  '), ',')
  " autoload/ plugin/ indent/

  lua myutils = require 'mia.utils'
  augroup vimrc_autosource
    autocmd!
    " execute "autocmd BufWritePost" pattern "source % | echo 'Sourced ' . expand('%')"
     autocmd BufWritePost autoload/*.vim,plugin/*.vim,indent/*.vim source % | echo 'Sourced ' . expand('%')
     if has('nvim')
       autocmd BufWritePost lua/*.lua echo v:lua.myutils.reload(expand('%:r:s?/?.?')[4:], expand('%'))
     endif
  augroup END
  echom 'Autosource set up on files matching: {autoload,plugin,indent}/*.vim, and lua/*.lua'
endfunction

command! -nargs=* AutoSourceEnable call s:setup_autosource(<f-args>)
command! AutoSourceDisable autocmd! vimrc_autosource
