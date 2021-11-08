local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local config = {
  sumneko_lua = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' }, -- lua version for neovim
        diagnostics = { globals = { 'vim' } }, -- recognize vim global
        -- Make the server aware of Neovim runtime files:
        -- workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
}

require('nvim-lsp-installer').on_server_ready(function(server)
  -- server:setup(get_options(server.name))
  server:setup(vim.tbl_deep_extend('force', {
    capabilities = capabilities,
  }, config['sumneko_lua']))
end)

require('lspconfig')['julials'].setup { capabilities = capabilities }
