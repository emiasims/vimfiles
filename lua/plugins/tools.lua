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
      'stevearc/conform.nvim',
      opts = {
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          markdown = { 'prettier', 'inject' },
        },
      },
      ---@param c {opts: conform.setupOpts}
      config = function(c)
        require('conform').setup(c.opts)
        mia.fmtexpr = mia.restore_opt( --
          { eventignore = 'all' },
          function()
            require('conform').formatexpr()
            vim.schedule_wrap(vim.cmd.doautocmd)('TextChanged')
          end
        )

        vim.o.formatexpr = 'v:lua.mia.fmtexpr()'
      end,
    },

    {
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      opts = {
        ensure_installed = {
          'basedpyright',
          'clangd',
          'emmylua_ls',
          'debugpy',
          'ruff-lsp',
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
