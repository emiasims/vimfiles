---@type LazySpec
return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'default',
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      ['<Plug>(miaCmpConfirm)'] = { 'select_and_accept' },
      cmdline = {
        preset = 'default',
        ['<Tab>'] = {},
        ['<S-Tab>'] = {},
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<Plug>(miaCmpConfirm)'] = { 'select_and_accept' },
      }
    },

    appearance = { use_nvim_cmp_as_default = true },
  },
}
