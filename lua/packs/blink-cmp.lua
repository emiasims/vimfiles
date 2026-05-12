vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = '*' },
  'https://github.com/rafamadriz/friendly-snippets',
  'https://github.com/garymjr/nvim-snippets',
}, { load = true })

local ctx = require('ctxmap.keymap')

ctx.set('c', '<Tab>', {
  { 'blink_visible', '<C-n>', remap = true },
  { 'fn.pumvisible()', '<C-n>' },
}, { default = vim.fn.wildtrigger })

ctx.set('c', '<S-Tab>', { 'blink_visible', '<C-p>', remap = true })

ctx.set({ 'i', 'c' }, '<C-.>', {
  { 'blink_visible', '<C-y><Cmd>lua vim.defer_fn(require("blink.cmp").show, 1)<Cr>', remap = true },
  { 'fn.pumvisible()', '<C-y><Cmd>lua require("blink.cmp").show()<Cr>' },
}, { default = '<Cmd>lua require("blink.cmp").show()<Cr>' })

ctx.set('c', '<S-Space>', {
  { 'fn.pumvisible()', '<C-y><Cmd>lua require("blink.cmp").show()<Cr>' },
  { 'blink_visible', '<C-y><Cmd>lua vim.schedule(require("blink.cmp").show)<Cr>', remap = true },
}, { default = '<Cmd>lua require("blink.cmp").show()<Cr>' })

require('blink.cmp').setup({
  keymap = {
    preset = 'default',
    ['<C-Space>'] = {},
    ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    ['<Plug>(miaCmpConfirm)'] = { 'select_and_accept' },
    ['<Plug>(miaCmpSuggest)'] = { 'show', 'show_documentation', 'hide_documentation' },
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
