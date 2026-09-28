stimpack.dev('mia', 'emiasims/ctx.map', { name = 'ctx.map' })

mia.keymap({
  { '<F1>', '<Plug>(ctx-debug)', mode = { 'n', 't', '!' } },
  { 'g0', '0', mode = { 'n', 'x', 'o' } },
  { 'g$', '$', mode = { 'n', 'x', 'o' } },
})

local ctx = require('ctx')
local text = require('ctx.library.text')

local pares = { '()', '[]', '{}', "''", '""' }

local function pair_pat(pair)
  local l, r = pair:sub(1, 1), pair:sub(2, 2)
  return vim.pesc(l) .. '(%s*)%#%1' .. vim.pesc(r)
end

local function nlpair_pat(pair)
  local l, r = pair:sub(1, 1), pair:sub(2, 2)
  return vim.pesc(l) .. '%s*\n%s*%#%s*\n%s*' .. vim.pesc(r)
end

local allowed = function() return text.after('%W') or text.eol() end
ctx.library.add('autopair', {
  allowed = allowed,
  quote_allowed = function() return (text.before('%W') or text.sol()) and allowed() end,
  complete = function() return text.after(vim.pesc(ctx.keymap.current().lhs)) end,
  in_pair = function() return vim.iter(pares):map(pair_pat):any(text.line) end,
  in_nlpair = function()
    return vim.iter(pares):map(nlpair_pat):any(function(pat) return text.lines(pat, 1) end)
  end,
})

ctx.keymap.set({ 'n', 'x', 'o' }, '0', {
  { "text.before('^%s+$')", '0' },
  { 'opt.wrap', 'g^' },
}, { default = '0^' })

ctx.keymap.set({ 'n', 'o' }, '$', { 'opt.wrap', 'g$' })

ctx.keymap.set('x', '$', { 'opt.wrap', 'g$h' }, { default = '$h' })

ctx.keymap.set('n', '<C-h>', { 'win.left', 'gT9<C-w>l' }, { default = '<C-w>h' })
ctx.keymap.set('n', '<C-l>', { 'win.right', 'gt9<C-w>h' }, { default = '<C-w>l' })

ctx.keymap.set('i', '<Esc>', { 'fn.pumvisible', '<C-e>' })
ctx.keymap.set('i', '<Cr>', { 'fn.pumvisible', '<C-y>' })

-- autopairs
ctx.keymap.add('i', '<Cr>', { 'autopair.in_pair', '<Cr><C-c>O' })

ctx.keymap.sets({
  mode = { 'i', 's' },
  ctx = 'autopair.allowed',
  { '(', '()<C-]><C-g>U<Left>' },
  { '[', '[]<C-]><C-g>U<Left>' },
  { '{', '{}<C-]><C-g>U<Left>' },
})

ctx.keymap.sets({
  mode = { 'i', 's' },
  ctx = 'autopair.complete',
  { ')', '<C-]><C-g>U<Right>' },
  { ']', '<C-]><C-g>U<Right>' },
  { '}', '<C-]><C-g>U<Right>' },
  { '"', '<C-]><C-g>U<Right>' },
  { "'", '<C-]><C-g>U<Right>' },
})

ctx.keymap.add({ 'i', 's' }, '"', { 'autopair.quote_allowed', '""<C-]><C-g>U<Left>' })
ctx.keymap.add({ 'i', 's' }, "'", { 'autopair.quote_allowed', "''<C-]><C-g>U<Left>" })
ctx.keymap.set({ 'i', 's' }, ' ', { 'autopair.in_pair', '  <C-g>U<Left>' })
ctx.keymap.set({ 'i', 's' }, '<BS>', {
  { 'autopair.in_pair', '<BS><Del>' },
  { 'autopair.in_nlpair', '<C-o>vwhobld' },
})

-- cmdline abbreviations
ctx.keymap.set('c', ' ', { 'cmd.start', 'lua ' })

ctx.keymap.sets({
  mode = 'ca',
  ctx = "cmd.start() and abbr.trigger(' ')",
  { 'eq', 'vsp|TSEditQuery' },
  { 'eqa', 'vsp|TSEditQueryUserAfter' },
  { 'T', 'vsplit|term' },
})

ctx.keymap.sets({
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
