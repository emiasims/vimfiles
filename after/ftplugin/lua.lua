-- vim.keymap.set('ia', '--as', [=[--[[@as ]]<Left><Left>]=], { buffer = true })

local ctx = require('ctx')

ctx.set('n', '~', {
  { 'ciwtrue<Esc>`[', ctx.treesitter.on_node('false') },
  { 'ciwfalse<Esc>`[', ctx.treesitter.on_node('true') },
}, { default = ctx.global, buffer = true })

ctx.set('ia', 'as', {
  '[[@as]]<Left><Left>',
  function()
    return ctx.text.prev(4) == '--as'
  end,
}, { buffer = true })
