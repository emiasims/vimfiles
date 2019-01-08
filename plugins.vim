scriptencoding utf-8

if !has('packages') || exists('$SUDO_USER')
  finish
endif

" minpac setup: {{{
function! PackInit() abort
  packadd minpac

  call minpac#init()
  call minpac#add('k-takata/minpac', {'type': 'opt'})

  call minpac#add('vim-scripts/python_match.vim')
  call minpac#add('jeetsukumaran/vim-pythonsense')
  call minpac#add('Vimjas/vim-python-pep8-indent')
  call minpac#add('vim-jp/syntax-vim-ex')

  call minpac#add('tpope/vim-repeat')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-commentary')
  call minpac#add('tpope/vim-unimpaired')

  call minpac#add('ap/vim-buftabline')
  call minpac#add('machakann/vim-highlightedyank')
  call minpac#add('itchyny/vim-cursorword')
  call minpac#add('christoomey/vim-tmux-navigator')
  call minpac#add('jeetsukumaran/vim-filebeagle')
  " if executable('fzf')
  call minpac#add('junegunn/fzf.vim')  " Slow?
  " endif
  call minpac#add('junegunn/vim-easy-align')

  call minpac#add('justinmk/vim-sneak')
  call minpac#add('wellle/targets.vim')
  call minpac#add('tommcdo/vim-exchange')

  call minpac#add('w0rp/ale')
  call minpac#add('mhinz/vim-signify')  " Slow?
  call minpac#add('ludovicchabant/vim-gutentags')

  call minpac#add('SirVer/ultisnips')  " Slow?
  " if executable('node') && executable('yarn')
  call minpac#add('neoclide/coc.nvim')
  " endif
  call minpac#add('neoclide/jsonc.vim')

  call minpac#add('vim-pandoc/vim-pandoc', {'type' : 'opt'})
  call minpac#add('vim-pandoc/vim-pandoc-syntax', {'type' : 'opt'})
  call minpac#add('mbbill/undotree', {'type' : 'opt'})  " TODO?
endfunction

command! PackUpdate call PackInit() | call minpac#update('', {'do': 'call minpac#status()'})
command! PackClean  call PackInit() | call minpac#clean()
command! PackStatus call PackInit() | call minpac#status()
" }}}

" vim-sneak {{{
nmap f <Plug>Sneak_f
nmap F <Plug>Sneak_F
xmap f <Plug>Sneak_f
xmap F <Plug>Sneak_F
omap f <Plug>Sneak_f
omap F <Plug>Sneak_F

nmap t <Plug>Sneak_t
nmap T <Plug>Sneak_T
xmap t <Plug>Sneak_t
xmap T <Plug>Sneak_T
omap t <Plug>Sneak_t
omap T <Plug>Sneak_T

nmap ; <Plug>Sneak_;
xmap ; <Plug>Sneak_;
nmap , <Plug>Sneak_,
xmap , <Plug>Sneak_,

nmap s <Plug>Sneak_s
nmap S <Plug>Sneak_S

" }}}
" vim-highlightedyank {{{
if !exists('##TextYankPost')
  nmap y <Plug>(highlightedyank)
  xmap y <Plug>(highlightedyank)
endif
" }}}
" vim-easy-align {{{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}}
" targets {{{
let g:targets_aiAI = 'aIAi'
" }}}
" vim-filebeagle {{{
let g:filebeagle_suppress_keymaps = 1
nmap <silent> <leader>- <Plug>FileBeagleOpenCurrentBufferDir
let g:loaded_netrwPlugin = 'v9999'
" }}}
" vim-commentary {{{
xmap gc  <Plug>Commentary
nmap gc  <Plug>Commentary
omap gc  <Plug>Commentary
nmap gcc <Plug>CommentaryLine
nmap cgc <Plug>ChangeCommentary
nmap gcu <Plug>Commentary<Plug>Commentary
" }}}
" vim-fugitive {{{
nnoremap <silent> <leader>dgl :call difference#gitlog()<cr>
" }}}
" thesaurus_query.vim {{{
let g:tq_map_keys = 0
let g:tq_use_vim_autocomplete = 0
" }}}
" vim-pandoc {{{
let g:pandoc#folding#fdc = 0
" }}}
" fzf.vim {{{
if executable('fzf')
  " TODO: command history: https://goo.gl/aGkUbx
  set runtimepath+=~/.fzf
  source ~/local/src/fzf/plugin/fzf.vim

  let $FZF_DEFAULT_COMMAND = 'ag -g ""'
  nnoremap <silent> <leader>af  :Files<CR>
  nnoremap <silent> <leader>f   :GFiles<CR>
  nnoremap <silent> <leader>gst :GFiles?<CR>
  nnoremap <silent> <leader>b   :Buffers<CR>
  nnoremap <silent> <leader>l   :Lines<CR>
  nnoremap <silent> <leader>/   :BLines<CR>
  nnoremap <expr> <silent> <leader>O    ':Tags<CR>' . "'" . expand('<cword>') . ' '
  nnoremap <silent> <leader>mr  :History<CR>
  nnoremap <silent> <leader>A   :Ag<CR>
  nnoremap <silent> <leader>ht  :Helptags<CR>
  nnoremap <silent> <leader>gal :Commits<CR>
  nnoremap <silent> <leader>gl :BCommits<CR>

  " TODO: :h K and :h 'keywordprg'
  nnoremap <expr> <silent> <F3> ':Ag<CR>' . get(b:, 'fzf_defprefix', '') . "'" . expand('<cword>') . ' '
  xnoremap <expr> <silent> <F3> ':y a<CR>:Ag<CR>' . get(b:, 'fzf_defprefix', '') . "'" . @a . ' '
  nnoremap <expr> <silent> <F5> ':Ag<CR>' . "'" . expand('<cword>') . get(b:, 'fzf_fsuffix', '')

  function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
  endfunction

  let g:fzf_action = {
        \ 'ctrl-q': function('s:build_quickfix_list'),
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit' }

  augroup vimrc_term_fzf
    autocmd!
    autocmd FileType python let b:fzf_defprefix = "'def | 'class "
    autocmd FileType python let b:fzf_fsuffix = '('

    if has('nvim')
      autocmd FileType fzf tunmap <buffer> <Esc>
      autocmd FileType fzf tunmap <buffer> <C-h>
      autocmd FileType fzf tunmap <buffer> <C-j>
      autocmd FileType fzf tunmap <buffer> <C-k>
      autocmd FileType fzf tunmap <buffer> <C-l>
    endif
  augroup END

  nnoremap <leader>ev :Files $CFGDIR<CR>

endif
" }}}
" vim-signify {{{
highlight link SignifyLineAdd             String
highlight link SignifyLineChange          Todo
highlight link SignifyLineDelete          Error
highlight link SignifyLineChangeDelete    SignifyLineChange
highlight link SignifyLineDeleteFirstLine SignifyLineDelete

highlight link SignifySignAdd             String
highlight link SignifySignChange          Todo
highlight link SignifySignDelete          Error
highlight link SignifySignChangeDelete    SignifyLineChange
highlight link SignifySignDeleteFirstLine SignifyLineDelete
let g:signify_vcs_list = ['git']
let g:signify_sign_delete = '-'
let g:signify_sign_change = '~'
let g:signify_skip_filetype = { 'markdown': 1 }
" }}}
" vim-buftabline {{{
highlight link BufTabLineActive   TabLineSel
highlight link BufTabLineCurrent  PmenuSel
highlight link BufTabLineHidden   TabLine
highlight link BufTabLineFill     TabLineFill
" }}}
" statusline {{{
hi link User1 TabLine
hi link User2 IncSearch
hi link User3 StatusLineTermNC
hi link User4 PmenuSel
hi link User5 IncSearch
hi link User6 WildMenu
hi link User7 DiffAdd
hi link User8 StatusLineTerm
hi link User9 StatusLineTerm
" }}}


if has('nvim')
  " ultisnips {{{
  let g:UltiSnipsSnippetDirectories = [$CFGDIR . '/snips', 'UltiSnips']
  " imap <tab>:
  " Expand snippet if possible.
  " if there is is a pumvisible, accept the next one.
  " TODO: detect if selected: autocmd MenuPopup & CompleteDone, map <C-n>
  let g:ulti_expand_or_jump_res = 0  " default value, just set once
  function! s:expand_snip_or_jump() abort
    call UltiSnips#ExpandSnippetOrJump()
    return g:ulti_expand_or_jump_res
  endfunction

  function! s:select_and_accept() abort
    return (pumvisible() ? "\<C-n>\<C-y>" : "\<Tab>")
  endfunction

  inoremap <silent> <Tab> <C-r>=<SID>expand_snip_or_jump() ? '' : <SID>select_and_accept()<CR>

  let g:UltiSnipsExpandTrigger = '<Nop>'  " prevent tab from being bound
  let g:UltiSnipsJumpForwardTrigger = '<Nop>'
  let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
  let g:UltiSnipsRemoveSelectModeMappings = 0
  " }}}
  " coc {{{
  inoremap <expr> <CR> pumvisible() ? "\<C-y><CR>" : "\<CR>"
  " }}}
  " ale {{{
  set signcolumn=yes
  let g:ale_sign_error = '✖'  " U-2716
  let g:ale_sign_warning = '⚠'  " U-26A0
  let g:ale_sign_style_error = '➤'  " U-27A4
  hi! link ALEErrorSign WarningMsg
  hi! link ALEWarningSign Constant

  augroup vimrc_ale
    autocmd!
    autocmd Filetype python let b:ale_linters = ['pycodestyle', 'pydocstyle', 'pyflakes']
  augroup END

  " }}}
  " vim-gutentags {{{
  if executable($HOME.'/local/bin/ctags')
    let g:gutentags_cache_dir = $DATADIR.'/tags'
    let g:gutentags_ctags_executable = $HOME.'/local/bin/ctags'
  else
    let g:gutentags_enabled = 0
  endif
  " }}}
endif

" Windows {{{
if has('win32')
  function! s:setup_guifont() abort
    Guifont! DejaVu Sans Mono:h9
  endfunction
  call defer#onidle('call s:setup_guifont()')
endif
" }}}

" vim: set ts=2 sw=2 tw=99 et :
