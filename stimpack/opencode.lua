stimpack.add({ 'nickjvandyke/opencode.nvim' })

local ctx = require('ctxmap')

ctx.keymap.sets({
  mode = 'ca',
  ctx = 'cmd.start',
  { 'oc', 'lua require("opencode").select()' },
  { 'ai', 'lua require("opencode").ask("@this: ", { submit = true })' },
})

ctx.keymap.sets({
  mode = 't',
  ctx = 'vim.b.bufinfo.type == "opencode"',
  { '<C-[>', function() require('opencode').command('session.half.page.up') end },
  { '<C-]>', function() require('opencode').command('session.half.page.down') end },
  { '<C-.>', function() require('opencode').toggle() end },
  { '<C-c>', '<C-\\><C-c>' },
  { '<Esc>', '<C-\\><Esc>' },
})

mia.keymap({
  { '<C-.>', function() require('opencode').toggle() end },
  { 'go', function() require('opencode').command('@this') end },
})
