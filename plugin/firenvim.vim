if exists('g:started_by_firenvim')
  packadd firenvim
  let g:firenvim_config = { 'localSettings': {
        \ '.*'                     : #{selector: '', priority: 0, cmdline: 'neovim'},
        \ 'mail\.google\.com'      : #{selector: 'div[role="textbox"]', priority: 1, takeover: 'empty'},
        \ 'outlook\.office365\.com': #{selector: 'div[role="textbox"]', priority: 1, takeover: 'empty'},
        \ 'github\.com'            : #{selector: 'textarea', priority: 1, takeover: 'empty'},
        \ } }
  setlocal laststatus=2
  set showtabline=0
  set guifont=DejaVu\ Sans\ Mono:h9
  nnoremap <buffer> ZZ :xa<Cr>
  nnoremap <buffer> ZQ :qa!<Cr>
  augroup vimrc_firenvim
    autocmd!
    " Not working
    " autocmd BufEnter * ++once if empty(getline(1)) && line('$') == 1 | startinsert! | endif
    autocmd BufEnter mail*,outlook* set filetype=mail
    autocmd InsertEnter,InsertLeave,TextChanged * ++nested write
    autocmd BufEnter github.com_*.txt set filetype=markdown
  augroup END
  set wrap
  set colorcolumn=100
  setlocal spell
endif
