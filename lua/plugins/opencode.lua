---@type LazySpec
return {
  'nickjvandyke/opencode.nvim',
  ctxmap = {
    {
      mode = 'ca',
      ctx = 'cmd.start',
      { 'oc', 'lua require("opencode").select()' },
      { 'ai', 'lua require("opencode").ask("@this: ", { submit = true })' },
    },
    {
      mode = 't',
      ctx = 'vim.b.bufinfo.type == "opencode"',
      { '<C-[>', function() require('opencode').command('session.half.page.up') end },
      { '<C-]>', function() require('opencode').command('session.half.page.down') end },
      { '<C-c>', '<Nop>', desc = 'Disable Ctrl-C in opencode session' },
      { '<Esc>', '<Esc>', desc = 'Make esc usable in opencode' },
      { '<C-.>', function() require('opencode').toggle() end },
    },
  },
  keys = {
    { '<C-.>', function() require('opencode').toggle() end },
    { 'go', function() require('opencode').command('@this') end },
  },
}
