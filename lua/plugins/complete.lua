---@type LazySpec
return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',
  event = 'InsertEnter',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'default',
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<Plug>(miaCmpConfirm)'] = { 'select_and_accept' },
    },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'codecompanion' },
      cmdline = {},
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
        codecompanion = {
          name = 'CodeCompanion',
          module = 'codecompanion.providers.completion.blink',
        },
      },
    },
    appearance = { use_nvim_cmp_as_default = true },
  },
}
