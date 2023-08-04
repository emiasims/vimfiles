return {
  'neovim/nvim-lspconfig',
  event = { 'BufNewFile', 'BufReadPost' },
  build = ':MasonUpdate',

  dependencies = {
    'mason.nvim',  -- defined in mason.lua
    'wbthomason/lsp-status.nvim',
    'L3MON4D3/LuaSnip',
    'williamboman/mason-lspconfig.nvim',
    'jose-elias-alvarez/null-ls.nvim',
  },
  config = function()
    require 'mason-lspconfig'.setup { ensure_installed = { 'pylsp', 'clangd' } }

    local lsp_status = require 'lsp-status'
    lsp_status.register_progress()
    local lspconfig = require 'lspconfig'

    local lua_globals = {
      'vim', 'nvim', 'newproxy', 'P',
      'eq', 're', 'pat', 'rep', 'rep1', 'choice',                 -- nvim-org
      'optional', 'describe', 'it', 'before_each', 'after_each',  -- plenary
      's', 'sn', 't', 'i', 'f', 'c', 'd', 'r',                    -- luasnip
    }

    lspconfig.lua_ls.setup {
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = { globals = lua_globals },
          workspace = {
            -- Make the server aware of Neovim runtime files:
            library = {
              vim.fn.getenv 'VIMRUNTIME' .. '/lua',
              vim.fn.stdpath 'config' .. '/lua',
            },
            checkThirdParty = false,
          },
          telemetry = { enable = false },
          hint = { enable = true },
          format = {
            enable = true,
            defaultConfig = {  -- must be strings
              indent_size = '2',
              quote_style = 'single',
              call_arg_parentheses = 'remove',
              trailing_table_separator = 'smart',
              align_continuous_assign_statement = 'false',
              align_continuous_rect_table_field = 'false',
              align_array_table = 'false',
              space_before_inline_comment = '2',
            },
          },
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

    lspconfig.tsserver.setup {}
    lspconfig.clangd.setup {}
    lspconfig.jsonls.setup {}
    lspconfig.vimls.setup {}
    lspconfig.julials.setup {}

    vim.diagnostic.config { virtual_text = false, signs = true, underline = true }

    nvim.create_augroup('mia-lsp', { clear = true })
    nvim.create_autocmd('LspAttach', {
      group = 'mia-lsp',
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local capabilities = client.server_capabilities
        if capabilities.documentFormattingProvider then
          vim.bo[ev.buf].formatexpr = 'v:lua.vim.lsp.formatexpr()'
        end
      end,
    })
  end,
}
