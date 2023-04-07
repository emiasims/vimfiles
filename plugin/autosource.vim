function! s:setup_autosource() abort " {{{1
  augroup vimrc_autosource
    autocmd!
    autocmd BufWritePost autoload/*.vim,plugin/*.vim,indent/*.vim,lua/*.lua ++nested source %
  augroup END
  echom 'Autosource set up on files matching: {autoload,plugin,indent}/*.vim, and lua/*.lua'
endfunction

augroup vimrc_srclua
  autocmd!
  autocmd SourceCmd *.lua call v:lua.require'mia.source'.reload_lua_module(expand('<amatch>'))
  " autocmd SourceCmd *queries/*.scm call v:lua.mia.source.set_query(expand('<amatch>'), v:true)
augroup END

command! AutoSourceEnable call s:setup_autosource()
command! AutoSourceDisable autocmd! vimrc_autosource
