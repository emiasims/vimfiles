local lsp = mia.on.call('vim.lsp.buf')

---@type LazySpec
return {

  'Bilal2453/luvit-meta',
  { 'lewis6991/nvim-test', lazy = true },
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        'mia',
        'lazy.nvim',
        'luvit-meta/library',
        { path = 'mini.notify', words = { 'MiniNotify' } },
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    enabled = mia.ide.enabled,
    event = 'VeryLazy',
    dependencies = { 'mason.nvim', 'wbthomason/lsp-status.nvim' },

    keys = {
      { 'gd', lsp.definition, desc = 'Goto Definition' },
      { 'gr', lsp.references, desc = 'Goto References' },
      { 'K', lsp.hover, desc = 'Show help' },
      { '\\ca', lsp.code_action, desc = 'Code Action' },
    },

    opts = {
      setup = {
        ts_ls = true,
        clangd = true,
        jsonls = true,
        vimls = true,
        julials = true,
        taplo = true,
        emmylua_ls = true,

        ruff = {
          settings = { organizeImports = false },
          -- disable ruff as hover provider to avoid conflicts with pyright
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
        },

        pyright = {
          settings = { python = { analysis = { diagnosticMode = 'workspace' } } },
        },
      },
    },

    config = function(cfg)
      local lsp_status = require('lsp-status')
      lsp_status.register_progress()

      vim.diagnostic.config({ virtual_text = false, signs = true, underline = true })
      ---@cast cfg.opts {setup: table<string, any>}
      for server, config in pairs(cfg.opts.setup) do
        if type(config) == 'table' then
          vim.lsp.config(server, config)
        end
      end
      vim.lsp.enable(vim.tbl_keys(cfg.opts.setup))
    end,
  },
}
