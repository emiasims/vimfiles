local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local config = {
  sumneko_lua = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' }, -- lua version for neovim
        diagnostics = {
          globals = {
            'vim', 'P', 'use', 'newproxy', 'str', 're', 'rep', 'choice',
            'optional', 'describe', 'it', 'before_each', 'after_each',
          },
        },
        -- Make the server aware of Neovim runtime files:
        -- workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = { maxLineLength = 100 },
        },
      },
    },
  },
}

require('nvim-lsp-installer').on_server_ready(function(server)
  server:setup(vim.tbl_deep_extend('force', {
    capabilities = capabilities,
  }, config[server.name] or {}))
end)

-- Requires separate setup, installed manually (add LanguageServer) in julia
require('lspconfig')['julials'].setup { capabilities = capabilities }

-- local function setup_format()
--   local g = vim.api.nvim_create_augroup('mia-lsp', { clear=true })
--   vim.api.nvim_create_autocmd('BufWritePre', { callback = function() vim.lsp.buf.formatting_sync() end, buffer = ? })
-- end
