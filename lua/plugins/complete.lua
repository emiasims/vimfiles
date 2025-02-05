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

      cmdline = {
        preset = 'none',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-c>'] = { 'cancel', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
      },
    },

    completion = {
      menu = {
        auto_show = function(ctx)
          return ctx.mode ~= 'cmdline'
        end,
      },
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
    appearance = { use_nvim_cmp_as_default = true },
  },
}
