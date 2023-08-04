vim.iter {
  tabstop = 4,
  shiftwidth = 4,
  foldminlines = 2,
  colorcolumn = '100',
}:each(function(name, value) vim.opt_local[name] = value end)

vim.iter {
  ipdb = "__import__('ipdb').set_trace()<Left><Esc>",
  pdb = "__import__('pdb').set_trace()<Left><Esc>",
  iem = "__import__('IPython').embed()<Left><Esc>",
  ['true'] = 'True',
  ['false'] = 'False',
  ['&&'] = 'and',
  ['||'] = 'or',
}:each(function(lhs, rhs) vim.keymap.set('ia', lhs, rhs, { buffer = true }) end)

vim.keymap.set('n', '\\ga', 'yiqva]p`[i.<Esc>e:silent! call repeat#set("\\ga")<Cr>', { buffer = true })
vim.keymap.set('n', '\\gA', 'ysiw"ysa"]X:silent!call repeat#set("\\gA")<Cr>', { buffer = true })

local ctx = require 'ctx'

ctx.set('n', '<C-a>',
  { 'ciwTrue<Esc>', ctx.treesitter.on_node 'false' },
  { default = '<Plug>SpeedDatingUp', buffer = true })

ctx.set('n', '<C-x>',
  { 'ciwFalse<Esc>', ctx.treesitter.on_node 'true' },
  { default = '<Plug>SpeedDatingDown', buffer = true })

nvim.buf_create_user_command(0, 'Outline', 'lvimgrep /\\v^\\s*%(def |class )/ % | lopen', {})
