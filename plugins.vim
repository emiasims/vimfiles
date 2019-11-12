if !has('packages') || exists('$SUDO_USER')
  finish
endif

" minpac {{{
if has('nvim')
  silent! packadd! vim-signify
  silent! packadd! vim-gutentags
  silent! packadd! coc.nvim
  silent! packadd! jsonc.vim
  silent! packadd! ultisnips
endif

command! PackUpdate call pack#update()
command! PackClean  call pack#clean()
command! PackStatus call pack#status()

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

let g:sneak#label = 1
let g:sneak#absolute_dir = 1

" }}}
" vim-tmux-navigator {{{
let g:tmux_navigator_disable_when_zoomed = 1
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
" Not working.
" command! GitDiff call difference#gitlog()
" }}}
" vim-clap {

nnoremap <silent> <leader>f  :Clap files<Cr>
nnoremap <silent> <leader>gf :Clap git_files<Cr>
nnoremap <silent> <leader>l  :Clap buffers<Cr>
nnoremap <silent> <leader>L  :Clap lines<Cr>
nnoremap <silent> <leader>y  :Clap yanks<Cr>
nnoremap <silent> <leader>A  :Clap grep<Cr>

nnoremap <silent> <leader>ev :Clap files ++finder=fd --type f "$CFGDIR"<Cr>

" TODO: autoload, :h clap-registering-providers
let g:clap_provider_ctags = {'source': function('tags#to_list'), 'sink': function('tags#sink')}

let g:clap_provider_grep_executable = 'ag'

" fzf still
nnoremap <silent> <leader>t :Tags<Cr>
nnoremap <silent> <leader>ev :Files $CFGDIR<Cr>

" nnoremap <silent> <leader>t :Clap tags<Cr>
"   nnoremap <expr> <silent> <leader>T    ':Tags<CR>' . "'" . expand('<cword>') . ' '

" }
" vim-signify {{{
augroup vimrc_signify
  autocmd!
  autocmd ColorScheme * highlight link SignifyLineAdd             String
  autocmd ColorScheme * highlight link SignifyLineChange          Todo
  autocmd ColorScheme * highlight link SignifyLineDelete          Error
  autocmd ColorScheme * highlight link SignifyLineChangeDelete    SignifyLineChange
  autocmd ColorScheme * highlight link SignifyLineDeleteFirstLine SignifyLineDelete

  autocmd ColorScheme * highlight link SignifySignAdd             String
  autocmd ColorScheme * highlight link SignifySignChange          Todo
  autocmd ColorScheme * highlight link SignifySignDelete          Error
  autocmd ColorScheme * highlight link SignifySignChangeDelete    SignifyLineChange
  autocmd ColorScheme * highlight link SignifySignDeleteFirstLine SignifyLineDelete
augroup END
let g:signify_vcs_list = ['git']
let g:signify_sign_delete = '-'
let g:signify_sign_change = '~'
let g:signify_skip_filetype = { 'markdown': 1 }
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
" undotree {{{
nnoremap <F8> :UndotreeToggle<CR>
let g:undotree_DiffAutoOpen = 0
let undotree_HighlightChangedText = 0
" }}}
" vim-org {{{
let g:org_bibtex_dirlist = ['~/org/literature']
" }}}
" coc.nvim {{{
imap <C-y> <Plug>(coc-snippets-expand)
if has('nvim')
  nmap <silent> ]e <Plug>(coc-diagnostic-next)
  nmap <silent> [e <Plug>(coc-diagnostic-prev)
endif
" for coc-calc
imap <expr> <C-e> getline('.') =~# '=\s*$' ? "\<C-o>\<Plug>(coc-calc-result-append)" : "\<C-o>\<Plug>(coc-calc-result-replace)"
" xmap <Tab> <Plug>(coc-snippets-select)

" }}}
" vim-gutentags {{{
let g:gutentags_cache_dir = $DATADIR.'/tags'
" }}}

" Windows {{{
if has('win32')
  function! s:setup_guifont() abort
    Guifont! DejaVu Sans Mono:h9
  endfunction
  call defer#onidle('call s:setup_guifont()')
endif
" }}}
