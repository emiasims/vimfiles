stimpack.add({
  'saghen/blink.lib',
  'saghen/blink.cmp',
  'rafamadriz/friendly-snippets',
  'garymjr/nvim-snippets',
})

local blink = require('blink.cmp')
blink.build():wait(60000) ---@diagnostic disable-line: undefined-field

blink.setup({
  keymap = {
    preset = 'default',
    ['<C-Space>'] = {},
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    ['<Cr>'] = { 'select_and_accept', 'fallback_to_mappings' },
    ['<C-p>'] = { 'show', 'select_prev', 'fallback_to_mappings' },
    ['<C-n>'] = { 'show', 'select_next', 'fallback_to_mappings' },
  },
  cmdline = {
    keymap = {
      preset = 'none',
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-y>'] = { 'select_and_accept', 'fallback' },
      ['<C-e>'] = { 'cancel', 'fallback' },
    },
  },
  sources = {
    default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
    providers = {
      lazydev = {
        name = 'LazyDev',
        module = 'lazydev.integrations.blink',
        score_offset = 100,
      },
    },
  },
})

local ctx = require('ctxmap')
ctx.context.add('blink_visible', blink.is_visible)

ctx.keymap.set('c', '<Tab>', {
  { 'blink_visible', '<C-n>', remap = true },
  { 'fn.pumvisible()', '<C-n>' },
}, { default = vim.fn.wildtrigger })

ctx.keymap.set('c', '<S-Tab>', { 'blink_visible', '<C-p>', remap = true })

ctx.keymap.set({ 'i', 'c' }, '<C-.>', {
  { 'blink_visible', '<C-y><Cmd>lua vim.defer_fn(require("blink.cmp").show, 1)<Cr>', remap = true },
  { 'fn.pumvisible()', '<C-y><Cmd>lua require("blink.cmp").show()<Cr>' },
}, { default = '<Cmd>lua require("blink.cmp").show()<Cr>' })

ctx.keymap.set('c', '<S-Space>', {
  { 'fn.pumvisible()', '<C-y><Cmd>lua require("blink.cmp").show()<Cr>' },
  { 'blink_visible', '<C-y><Cmd>lua vim.schedule(require("blink.cmp").show)<Cr>', remap = true },
}, { default = '<Cmd>lua require("blink.cmp").show()<Cr>' })

-- have defaults in _ctxmap.lua
ctx.keymap.add('i', '<Esc>', { 'blink_visible', '<C-e>', remap = true })
ctx.keymap.add('c', ' ', { 'blink_visible', '<Cmd>lua require("blink.cmp").hide()<CR> ' })
