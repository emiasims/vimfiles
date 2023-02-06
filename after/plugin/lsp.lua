-- needs to be before lspconfig
require('mason').setup()
require('mason-lspconfig').setup { ensure_installed = { 'pylsp', 'sumneko_lua', 'vimls', 'clangd' } }

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

require('lspconfig').sumneko_lua.setup {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' }, -- lua version for neovim
      diagnostics = {
        globals = lua_globals,
      },
      -- Make the server aware of Neovim runtime files:
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
}

require('lspconfig').pylsp.setup {
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { maxLineLength = 100 },
      },
    },
  },
}

vim.diagnostic.config({ virtual_text = false, signs = true, underline = true })

vim.api.nvim_create_augroup('mia-lsp', { clear = true })
-- vim.api.nvim_create_autocmd('LspAttach', {
--   group = 'mia-lsp',
--   desc = 'Format on save',
--   callback = function() vim.lsp.buf.signature_help() end,
-- })


vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.get_client_by_id(args.data.client_id).server_capabilities.semanticTokensProvider = nil
  end,
})
