-- vim.pack.add({ 'https://github.com/emiasims/ctx.map' }, { load = true }) -- TODO

mia.keymap({
  { '<F1>', '<Plug>(ctxmap-debug)', mode = { 'n', 't', '!' } },
  { 'g0', '0', mode = { 'n', 'x', 'o' } },
  { 'g$', '$', mode = { 'n', 'x', 'o' } },
})

require('ctxmap').setup({
  fix_abbr_expansion = true,
  contexts = {
    ws_precursor = 'text.before("^%s*$")',
    blink_visible = 'require("blink.cmp").is_visible()',
    cmd_start_sp = 'cmd.start(lhs, map) and abbr.trigger(" ")',
    autopair = {
      allowed = 'text.after("%W") or text.eol()',
      quote_allowed = '(text.before("%W") or text.sol()) and autopair.allowed()',
      complete = 'text.after(vim.pesc(lhs))',

      pares = { '()', '[]', '{}', "''", '""' },
      pat = function(pair)
        local l, r = pair:sub(1, 1), pair:sub(2, 2)
        return vim.pesc(l) .. '(%s*)%#%1' .. vim.pesc(r)
      end,
      nlpat = function(pair)
        local l, r = pair:sub(1, 1), pair:sub(2, 2)
        return vim.pesc(l) .. '%s*\n%s*%#%s*\n%s*' .. vim.pesc(r)
      end,
      in_pair = 'vim.iter(autopair.pares):map(autopair.pat):any(text.line)',
      in_nlpair = 'vim.iter(autopair.pares):map(autopair.nlpat):any(lines.surround(1))',
    },
  },
})

local ctx = require('ctxmap.keymap')

ctx.set({ 'n', 'x', 'o' }, '0', {
  { 'text.before("^%s+$")', '0' },
  { 'opt.wrap', 'g^' },
}, { default = '0^' })

ctx.set({ 'n', 'o' }, '$', { 'opt.wrap', 'g$' })

ctx.set('x', '$', { 'opt.wrap', 'g$h' }, { default = '$h' })

ctx.set('n', '<C-h>', { 'win.left', 'gT9<C-w>l' }, { default = '<C-w>h' })

ctx.set('n', '<C-l>', { 'win.right', 'gt9<C-w>h' }, { default = '<C-w>l' })

ctx.set('i', '<Esc>', {
  { 'fn.pumvisible()', '<C-e>' },
  { 'blink_visible', '<C-e>', remap = true },
})

ctx.set('i', '<Cr>', {
  { 'blink_visible', '<Plug>(miaCmpConfirm)' },
  { 'fn.pumvisible()', '<C-y>' },
  { 'autopair.in_pair', '<Cr><C-c>O' },
})

ctx.sets({
  mode = { 'i', 's' },
  ctx = 'autopair.allowed',
  { '(', '()<C-]><C-g>U<Left>' },
  { '[', '[]<C-]><C-g>U<Left>' },
  { '{', '{}<C-]><C-g>U<Left>' },
})

ctx.sets({
  mode = { 'i', 's' },
  ctx = 'autopair.complete',
  { ')', '<C-]><C-g>U<Right>' },
  { ']', '<C-]><C-g>U<Right>' },
  { '}', '<C-]><C-g>U<Right>' },
  { '"', '<C-]><C-g>U<Right>' },
  { "'", '<C-]><C-g>U<Right>' },
})

ctx.set({ 'i', 's' }, '"', { 'autopair.quote_allowed', '""<C-]><C-g>U<Left>' }, { clear = false })

ctx.set({ 'i', 's' }, "'", { 'autopair.quote_allowed', "''<C-]><C-g>U<Left>" }, { clear = false })

ctx.set({ 'i', 's' }, ' ', { 'autopair.in_pair', '  <C-g>U<Left>' })

ctx.set({ 'i', 's' }, '<BS>', { 'autopair.in_pair', '<BS><Del>' })

ctx.set({ 'i', 's' }, '<BS>', { 'autopair.in_nlpair', '<C-o>vwhobld' }, { clear = false })

ctx.set('c', ' ', {
  { 'cmd.start', 'lua ' },
  { 'blink_visible', '<Cmd>lua require("blink.cmp").hide()<CR> ' },
})

ctx.sets({
  mode = 'ca',
  ctx = 'cmd.start(lhs, map) and abbr.trigger(" ")',
  { 'eq', 'vsp|TSEditQuery' },
  { 'eqa', 'vsp|TSEditQueryUserAfter' },
  { 'T', 'vsplit|term' },
})

ctx.sets({
  mode = 'ca',
  ctx = 'cmd.start',
  { 'sq', 'Session quit' },
  { 'qq', 'Session quit' },
  { 'sr', 'Session renew' },

  { 'he', 'help' },
  { 'eft', 'EditFtplugin' },
  { 'eq', 'vsp|TSEditQuery highlights' },
  { 'eqa', 'vsp|TSEditQueryUserAfter highlights' },
  { 'es', 'vertical EditSnippets' },
  { 'e!', 'mkview | edit!' },
  { 'use', 'UltiSnipsEdit' },
  { 'ase', 'AutoSourceEnable' },
  { 'asd', 'AutoSourceDisable' },
  { 'vga', 'vimgrep // **/*.<C-r>=expand("%:e")<Cr><C-Left><Left><Left>', eat = '%s' },
  { 'ccle', 'Cclearquickfix' },
  { 'cclear', 'Cclearquickfix' },
  { 'lcle', 'Lclearloclist' },
  { 'lclear', 'Lclearloclist' },
  { 'lf', 'luafile%' },
  { 'w2', 'w' },
  { 'dws', 'mkview | silent! %s/\\v(\\s+|\\r)$// | loadview | update' },
  { 'eh', 'edit <C-r>=expand("%:h")<Cr>/', eat = ' ' },
  { 'mh', 'Move <C-r>=expand("%:h")<Cr>/', eat = '%s' },
  { 'mf', 'edit <C-r>=stdpath("config")<Cr>/lua/mia/<C-z>', eat = ' ' },
  { 'T', 'execute v:lua.mia.termopen()|startinsert' },
  { 'term', 'term fish' },
  { 'res', 'restart Session load last' },

  { 'wc', 'vnew | r# | setlocal | buftype=nofile | let &ft=getbufvar("#", "&ft")' },
  { 'tc', 'let s=&ssop | set ssop=blank,help,folds,winsize,localoptions | let f=tempname() | exe "mksession " . f | tabnew | exe "source " . f | call delete(f) | let &ssop=s' },
  { 'tmp', 'let w=bufnr()|let w=win_getid()|tabprev|vsplit|exe "b" . b|call win_execute(w, "close")|unlet! b w' },
  { 'tmn', 'let b=bufnr()|let w=win_getid()|tabnext|topleft vsplit|exe "b" . b|call win_execute(w, "close")|unlet! b w' },
  { 'tsl', 'wincmd T' },
  { 'tsp', 'tab split' },
})
