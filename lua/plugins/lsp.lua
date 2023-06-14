return {
  'neovim/nvim-lspconfig',
  event = { 'BufNewFile', 'BufReadPost' },
  build = ':MasonUpdate',

  dependencies = {
    'mason.nvim', -- defined in mason.lua
    'wbthomason/lsp-status.nvim',
    'L3MON4D3/LuaSnip',
    'williamboman/mason-lspconfig.nvim',
    'jose-elias-alvarez/null-ls.nvim',
  },
  config = function()
    require('mason-lspconfig').setup { ensure_installed = { 'pylsp', 'clangd' } }

    local lsp_status = require('lsp-status')
    lsp_status.register_progress()
    local lspconfig = require('lspconfig')

    local lua_globals = {
      'vim',
      'newproxy',                                                -- builtin
      'P',                                                       -- mia, print vim.inspect
      'eq', 're', 'pat', 'rep', 'rep1', 'choice',                -- nvim-org
      'optional', 'describe', 'it', 'before_each', 'after_each', -- plenary
    }

    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          runtime = { version = '5.1' }, -- lua version for neovim
          -- runtime = { version = 'LuaJIT' }, -- lua version for neovim
          diagnostics = { globals = lua_globals },
          -- Make the server aware of Neovim runtime files:
          workspace = {
            -- library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    }

    lspconfig.pylsp.setup {
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = { maxLineLength = 100 },
          },
        },
      },
    }

    lspconfig.tsserver.setup({})

    vim.diagnostic.config({ virtual_text = false, signs = true, underline = true })

    vim.api.nvim_create_augroup('mia-lsp', { clear = true })
    vim.api.nvim_create_autocmd("LspAttach", {
      group = 'mia-lsp',
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        -- client.server_capabilities.semanticTokensProvider = nil
        if client.server_capabilities.documentFormattingProvider then
          vim.bo[ev.buf].formatexpr = "v:lua.vim.lsp.formatexpr()"
        end
      end,
    })
  end
}
