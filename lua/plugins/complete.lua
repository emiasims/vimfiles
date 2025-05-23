---@type LazySpec
return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',
  event = { 'InsertEnter', 'CmdlineEnter' },
  version = '*',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {

    keymap = {
      preset = 'default',
      ['<C-Space>'] = {}, -- <Plug>(miaCmpSuggest)
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<Plug>(miaCmpConfirm)'] = { 'select_and_accept' },
      ['<Plug>(miaCmpSuggest)'] = { 'show', 'show_documentation', 'hide_documentation' },
    },

    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'codecompanion' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
        -- not necessary if not lazy loading codecompanion
        codecompanion = {
          name = 'CodeCompanion',
          module = 'codecompanion.providers.completion.blink',
        },
      },
    },
  },
}
