-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

local lua_globals = {
  'vim',
  'mia',
  'newproxy', -- builtin
  'P', -- mia, print vim.inspect
  'use', -- packer
  'eq', 're', 'pat', 'rep', 'rep1', 'choice', -- nvim-org
  'optional', 'describe', 'it', 'before_each', 'after_each', -- plenary
  'lhs', -- contextualize
}
vim.list_extend(lua_globals, vim.tbl_keys(require('contextualize.fenv')))

local config = {
  sumneko_lua = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' }, -- lua version for neovim
        diagnostics = {
          globals = lua_globals,
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

vim.api.nvim_create_augroup('mia-lsp', { clear = true })

-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = { '*.py', '*.lua' },
--   group = 'mia-lsp',
--   desc = 'Format on save',
--   callback = function() vim.lsp.buf.format() end,
-- })

