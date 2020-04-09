if !has('packages') || exists('$SUDO_USER')
  finish
endif

" minpac {{{1
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


" vim-sneak {{{1
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
let g:sneak#use_ic_scs = 1

" vim-tmux-navigator {{{1
let g:tmux_navigator_disable_when_zoomed = 1
" targets {{{1
let g:targets_aiAI = 'aIAi'
" vim-filebeagle {{{1
let g:filebeagle_suppress_keymaps = 1
nmap <silent> <leader>- <Plug>FileBeagleOpenCurrentBufferDir
let g:loaded_netrwPlugin = 'v9999'
" vim-matchup {{{1
let g:matchup_matchparen_offscreen = {}
" vim-commentary {{{1
xmap gc  <Plug>Commentary
nmap gc  <Plug>Commentary
omap gc  <Plug>Commentary
nmap gcc <Plug>CommentaryLine
nmap cgc <Plug>ChangeCommentary
nmap gcu <Plug>Commentary<Plug>Commentary
" fzf {{{1
" add fzf path if not already in it

let fzpath = resolve(expand('<sfile>:h')) . '/pack/minpac/start/fzf/bin'
let fzpath .= '\|' . expand('<sfile>:h') . '/pack/minpac/start/fzf/bin'
if $PATH !~# fzpath
  let $PATH = expand('<sfile>:h') . '/pack/minpac/start/fzf/bin:' . $PATH
endif
unlet fzpath

let $FZF_DEFAULT_COMMAND = 'ag -g ""'
let g:fzf_preview_window = ''

nnoremap <silent> <leader>af  :FZ 50 20 \| Files<CR>
nnoremap <silent> <leader>f   :FZ 40 20 \| GFiles<CR>
nnoremap <silent> <leader>o   :FZ 40 20 \| Files ~/org<CR>
nnoremap <silent> <leader>gst :FZ 120 40 \| GFiles?<CR>
nnoremap <silent> <leader>b   :Lines<CR>
nnoremap <silent> <leader>l   :<C-u>call fzfr#buffers()<Cr>
nnoremap <silent> <leader>/   :BLines<CR>
" nnoremap <silent> <leader>t   :<C-u>call fzfr#tags()<CR>
nnoremap <silent> <leader>t   :FZ 80 20 \| Tags<CR>
nnoremap <silent> <leader>mr  :FZ 70 20 \| History<CR>
nnoremap <silent> <leader>A   :Ag<CR>
nnoremap <silent> <leader>h   :FZ 80 20 \| Helptags<CR>
nnoremap <silent> <leader>gal :FZ 160 20 \| Commits<CR>
nnoremap <silent> <leader>gl  :FZ 160 20 \| BCommits<CR>
nnoremap <leader>ev           :FZ 70 20 \| Files $CFGDIR<CR>
if has('nvim')
  let g:fzf_layout = { 'window': 'call fzfr#floating_win()' }
endif

" vim-signify {{{1
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
" statusline {{{1
hi link User1 TabLine
hi link User2 IncSearch
hi link User3 StatusLineTermNC
hi link User4 PmenuSel
hi link User5 IncSearch
hi link User6 WildMenu
hi link User7 DiffAdd
hi link User8 StatusLineTerm
hi link User9 StatusLineTerm
" undotree {{{1
nnoremap <F8> :UndotreeToggle<CR>
let g:undotree_DiffAutoOpen = 0
let undotree_HighlightChangedText = 0
" vim-org {{{1

let g:org#capture#templates = {}
let t = g:org#capture#templates
let t.n = {'type': 'entry', 'description': 'Note', 'target': 'inbox.org/Notes'}
let t.i = {'type': 'entry', 'description': 'Idea', 'target': 'box.org'}
let t.e = {'type': 'entry', 'description': 'Event', 'target': 'events.org'}
let t.t = {'type': 'entry', 'description': 'TODO item'}
let t.b = {'type': 'entry', 'description': 'Shopping item', 'target': 'shopping.org/Capture'}

let t.w = {'type': 'entry', 'description': 'Work TODO'}
let t.p = {'type': 'checkitem', 'description': 'Work TODO: Paper'}
let t.p.target = 'literature.org/Papers to Lookup'
let t.p.opts = {'quit': 1}

let t.b.snippet = 1
let projecttemplate =<< ENDORGTMPL
${1:Description}
:PROPERTIES:
:captured-at: `!v org#timestamp#date2text(localtime())`
:END:
$0
ENDORGTMPL

function! s:pname() abort
  return matchstr(fnamemodify(expand('%'), ':p:~'), '^\~/Projects/\zs[^/]\+')
endfunction

let t.e.snippet = 1
let t.e.template = ['${1:Event}', '<${1:now}>']

let t.b.template =<< ENDORGTMPL
${0:I NEEEED IT}
:PROPERTIES:
:captured-at: `!v org#timestamp#date2text(localtime())`
:captured-in: `!o resolve(fnamemodify(expand('%'), ':p:~'))`
:END:
ENDORGTMPL
let t.b.snippet = 1

nmap <leader>c <Plug>(org-capture)
xmap <leader>c <Plug>(org-capture)
unlet t

let g:org#capture#opts = {'editcmd': 'JumpSplitOrEdit'}

" coc.nvim {{{1
if has('nvim')
  nmap <silent> ]e <Plug>(coc-diagnostic-next)
  nmap <silent> [e <Plug>(coc-diagnostic-prev)
" for coc-calc
imap <expr> <C-e> getline('.') =~# '=\s*$' ? "\<C-o>\<Plug>(coc-calc-result-append)" : "\<C-o>\<Plug>(coc-calc-result-replace)"

endif
" Ultisnips {{{1
let g:UltiSnipsEditSplit = 'tabdo'
let g:UltiSnipsSnippetDirectories = ['snips']
let g:UltiSnipsRemoveSelectModeMappings = 0
" let g:UltiSnipsExpandTrigger = '<Tab>'
" let g:UltiSnipsJumpForwardTrigger = '<Tab>'
" let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
let g:UltiSnipsExpandTrigger = "<Plug>(myUltiSnipsExpand)"
let g:UltiSnipsJumpForwardTrigger = "<Plug>(myUltiSnipsForward)"
let g:UltiSnipsJumpBackwardTrigger = "<Plug>(myUltiSnipsBackward)"
imap <Tab> <Plug>(myUltiSnipsExpand)
xmap <Tab> <Plug>(myUltiSnipsExpand)
snoremap <C-e> <Esc>`>a
" Contextualize {{{1
packadd contextualize.vim

autocmd! User UltiSnipsEnterFirstSnippet
autocmd! User UltiSnipsExitLastSnippet
autocmd User UltiSnipsEnterFirstSnippet let g:in_snippet = 1
autocmd User UltiSnipsExitLastSnippet let g:in_snippet = 0
let g:in_snippet = 0
ContextAdd parens {-> getline('.')[col('.') - 1 :] =~# '^[\])}''"]\{2,}'}
ContextAdd insnippet {-> g:in_snippet}
Contextualize parens inoremap <Tab> <C-o>/[^\])}'"]\\|$<Cr>
Contextualize insnippet imap <Tab> <Plug>(myUltiSnipsForward)
Contextualize insnippet imap <S-Tab> <Plug>(myUltiSnipsBackward)

ContextAdd startcmd {-> getcmdtype()==":" && getcmdline()==self.lhs}

Contextualize startcmd cnoreabbrev he help
Contextualize startcmd cnoreabbrev h vert help
Contextualize startcmd cnoreabbrev <expr> eft 'edit $CFGDIR/after/ftplugin/' . &filetype . '.vim'
Contextualize startcmd cnoreabbrev e! mkview \| edit!
Contextualize startcmd cnoreabbrev use UltiSnipsEdit
Contextualize startcmd cnoreabbrev ase AutoSourceEnable
Contextualize startcmd cnoreabbrev asd AutoSourceDisable
Contextualize startcmd cnoreabbrev sr SetRepl
Contextualize startcmd cnoreabbrev tr TermRepl
Contextualize startcmd cnoreabbrev <expr> vga 'vimgrep // **/*.' . expand('%:e') . "\<C-Left><Left><Left>"
Contextualize startcmd cnoreabbrev cqf Clearqflist

" vim-fugitive {{{1
Contextualize startcmd cnoreabbrev gcim Gcommit \| startinsert

" vim-gutentags {{{1
let g:gutentags_cache_dir = $DATADIR.'/tags'
" firenvim {{{1
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

" Windows {{{1
if has('win32')
  function! s:setup_guifont() abort
    Guifont! DejaVu Sans Mono:h9
  endfunction
  call defer#onidle('call s:setup_guifont()')
endif
