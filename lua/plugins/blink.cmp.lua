---@type LazySpec
return {
  'saghen/blink.cmp',
  enable = mia.ide.enabled,
  dependencies = 'rafamadriz/friendly-snippets',
  event = { 'InsertEnter', 'CmdlineEnter' },
  version = '*',

  keys = {
    { '<S-Space>', '<C-e><Cmd>lua require("blink.cmp").show_and_insert_or_accept_single()<Cr>', mode = 'c' },
  },

  -- wildchar does weird things with blink and also popup menus
  ctxmap = {
    {
      '<Tab>',
      {
        { 'blink_visible', '<C-n>', remap = true },
        { 'fn.pumvisible()', '<C-n>' },
      },
      mode = 'c',
      default = 'vim.fn.wildtrigger()',
    },
    { '<S-Tab>', { 'blink_visible', '<C-p>', remap = true }, mode = 'c' },
  },

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {

    keymap = {
      preset = 'default',
      ['<C-Space>'] = {}, -- <Plug>(miaCmpSuggest)
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
          enabled = mia.ide.enabled,
          name = 'CodeCompanion',
          module = 'codecompanion.providers.completion.blink',
        },
      },
    },
  },
}
