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
  ['\\b'] = 'β',
  ['\\g'] = 'γ',
  ['\\t'] = 'τ',
}:each(function(lhs, rhs) vim.keymap.set('ia', lhs, rhs, { buffer = true }) end)

local ctx = require 'ctx'

ctx.set('n', '\\ga', {
  { 'yiqva]p`[i.<Esc>e', ctx.treesitter.in_node 'subscript', remap = true },
  { '<Plug>Ysurroundiw"<Plug>Ysurrounda"]X%', ctx.treesitter.in_node 'attribute', remap = true},
}, { buffer = true })  -- remap?

ctx.set('n', '~', {
  { 'ciwTrue<Esc>`[', ctx.treesitter.on_node 'false' },
  { 'ciwFalse<Esc>`[', ctx.treesitter.on_node 'true' },
}, { default = ctx.global, buffer = true })

vim.keymap.set('n', 'gO', '<cmd>lvimgrep /\\v^\\s*%(def |class )/ % | lopen<Cr>', { buffer = true })
