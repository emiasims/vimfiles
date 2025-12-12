---@type LazySpec
return {
  'williamboman/mason.nvim',
  enabled = mia.ide.enabled,
  build = ':MasonUpdate',
  lazy = true,
  config = true,
  dependencies = {
    'jose-elias-alvarez/null-ls.nvim',
    'williamboman/mason-lspconfig.nvim',
    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = {
          'basedpyright',
          'clangd',
          'lua_ls',
          'debugpy',
          'ruff',
          'black',
          'isort',
          'stylua',
          'vimls',
          'pylsp',
          'jsonls',
        },
      },
    },
  },
}
