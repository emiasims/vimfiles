if !has('packages') || exists('$SUDO_USER')
  finish
endif

" minpac {{{
if has('nvim')
  if !exists('g:started_by_firenvim')
    silent! packadd! vim-signify
    silent! packadd! vim-gutentags
    silent! packadd! coc.nvim
    silent! packadd! jsonc.vim
  endif
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
" vim-matchup {{{
let g:matchup_matchparen_offscreen = {}
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
" fzf {{{
let $FZF_DEFAULT_COMMAND = 'ag -g ""'
nnoremap <silent> <leader>af  :Files<CR>
nnoremap <silent> <leader>f   :GFiles<CR>
nnoremap <silent> <leader>o   :Files ~/org<CR>
nnoremap <silent> <leader>gst :GFiles?<CR>
nnoremap <silent> <leader>b   :Lines<CR>
nnoremap <silent> <leader>l   :Buffers<CR>
nnoremap <silent> <leader>/   :BLines<CR>
nnoremap <silent> <leader>t   :Tags<CR>
nnoremap <silent> <leader>mr  :History<CR>
nnoremap <silent> <leader>A   :Ag<CR>
nnoremap <silent> <leader>h   :Helptags<CR>
nnoremap <silent> <leader>gal :Commits<CR>
nnoremap <silent> <leader>gl  :BCommits<CR>

nnoremap <leader>ev :Files $CFGDIR<CR>
if has('nvim')
  let g:fzf_layout = { 'window': 'call fzf#floating_win()' }
endif

" function! s:build_quickfix_list(lines)
"   call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
"   copen
"   cc
" endfunction

" let g:fzf_action = {
"       \ 'ctrl-q': function('s:build_quickfix_list'),
"       \ 'ctrl-s': 'split',
"       \ 'ctrl-v': 'vsplit' }

" augroup vimrc_term_fzf
"   autocmd!
"   autocmd FileType python let b:fzf_defprefix = "'def | 'class "
"   autocmd FileType python let b:fzf_fsuffix = '('
" augroup END

" }}}
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

let g:org#capture#templates = {}
let t = g:org#capture#templates

let t.n = {'type': 'entry', 'description': 'Note', 'target': 'inbox.org/Notes'}
let t.e = {'type': 'entry', 'description': 'Event', 'target': 'events.org'}
let t.t = {'type': 'entry', 'description': 'TODO item'}
let t.b = {'type': 'entry', 'description': 'Shopping item', 'target': 'shopping.org/Capture'}

let t.w = {'type': 'entry', 'description': 'Work TODO'}
let t.wp = {'type': 'checkitem', 'description': 'Work TODO: Paper'}
let t.wp.target = 'literature.org/Papers to Lookup'
let t.wp.opts = {'quit': 1}
let t.ws = {'type': 'entry', 'description': 'Work TODO: Simulations', 'target': 'work.org/Project Ideas'}
let t.wi = {'type': 'entry', 'description': 'Work project idea', 'target': 'work.org/Project Ideas'}

let t.pv = {'type': 'entry', 'description': 'Project TODO: vim', 'target': 'vim.org'}
let t.po = {'type': 'entry', 'description': 'Project TODO: vim-org', 'target': 'vim.org/vim-org/Capture'}
let t.ps = {'type': 'entry', 'description': 'Project TODO: simbiofilm', 'target': 'work.vim/simbiofilm'}

let projecttemplate =<< ENDTMPL
* TODO `input("Project TODO> ")`
:PROPERTIES:
:captured-at: `org#timestamp#date2text(localtime())`
:captured-in: `resolve(fnamemodify(expand('%'), ':p:~'))`
:END:
ENDTMPL

let t.e.template =<< ENDTMPL
* `input("Name> ")`
`input("Datetime> ", "", "customlist,org#timestamp#completion")`
:PROPERTIES:
:captured-at: `org#timestamp#date2text(localtime())`
:END:
ENDTMPL

let t.b.template =<< ENDTMPL
${0:I NEEEED IT}
:PROPERTIES:
:captured-at: `!v org#timestamp#date2text(localtime())`
:captured-in: `!o resolve(fnamemodify(expand('%'), ':p:~'))`
:END:
ENDTMPL
let t.b.snippet = 1

nmap <leader>c <Plug>(org-capture)
xmap <leader>c <Plug>(org-capture)

let g:org#capture#opts = {'editcmd': 'SmartSplit'}

" }}}
" coc.nvim {{{
if has('nvim')
  nmap <silent> ]e <Plug>(coc-diagnostic-next)
  nmap <silent> [e <Plug>(coc-diagnostic-prev)
" for coc-calc
imap <expr> <C-e> getline('.') =~# '=\s*$' ? "\<C-o>\<Plug>(coc-calc-result-append)" : "\<C-o>\<Plug>(coc-calc-result-replace)"

" imap <C-y> <Plug>(coc-snippets-expand)
" xmap <Tab> <Plug>(coc-snippets-select)
endif

" Ultisnips {{{
let g:UltiSnipsEditSplit = 'tabdo'
let g:UltiSnipsSnippetDirectories = ['snips']
let g:UltiSnipsRemoveSelectModeMappings = 0
let g:UltiSnipsExpandTrigger = '<Tab>'
let g:UltiSnipsJumpForwardTrigger = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
" }}}

" }}}
" vim-gutentags {{{
let g:gutentags_cache_dir = $DATADIR.'/tags'
" }}}
" firenvim {{{
if exists('g:started_by_firenvim')
  let g:firenvim_config = {'localSettings': {'.*': { 'selector': '', 'priority': 0, },
        \ 'mail\.google\.com': {'selector': 'div[role="textbox"]', 'priority': 1, 'takeover': 'empty'},
        \ 'outlook\.office365\.com': {'selector': 'div[role="textbox"]', 'priority': 1, 'takeover': 'empty'},
        \ 'github\.com': {'selector': 'textarea', 'priority': 1, 'takeover': 'once'},
        \ }}
  setlocal laststatus=0
  set showtabline=0
  let g:loaded_statusline = 1
  set guifont=DejaVu\ Sans\ Mono:h9
  nnoremap ZZ :xa<Cr>
  nnoremap ZQ :qa!<Cr>
  nnoremap <Esc><Esc> :call firenvim#focus_page()<Cr>
  augroup vimrc_firenvim
    autocmd!
    " Not working
    autocmd BufEnter * ++once if empty(getline(1)) && line('$') == 1 | startinsert! | endif
    autocmd BufEnter mail*,outlook* set filetype=mail
    autocmd TextChanged * ++nested write
    autocmd InsertEnter,InsertLeave * ++nested write
    autocmd BufEnter github.com_*.txt set filetype=markdown
  augroup END
  set wrap
  set colorcolumn=100
  setlocal spell
endif
" }}}

" Windows {{{
if has('win32')
  function! s:setup_guifont() abort
    Guifont! DejaVu Sans Mono:h9
  endfunction
  call defer#onidle('call s:setup_guifont()')
endif
" }}}
