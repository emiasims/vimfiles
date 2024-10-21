local lsp = mia.on.call('vim.lsp.buf')

---@type LazySpec
return {

  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        -- Library paths can be absolute
        -- '~/projects/my-awesome-lib',
        'lazy.nvim',
        'luvit-meta/library',
        -- 'mini.notify',
        { path = 'mini.notify', words = { 'MiniNotify' } },
        { path = 'mia', words = { 'mia' } },
        -- TODO build a cache of paths and words

        -- It can also be a table with trigger words / mods
        -- Only load luvit types when the `vim.uv` word is found
        -- { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = { 'mason.nvim', 'wbthomason/lsp-status.nvim' },

    -- 'mason-lspconfig.nvim',
    -- 'mason-tool-installer.nvim',

    keys = {
      -- 'gd', 'gr', 'K', '\\ca'
      { 'gd', lsp.definition, desc = 'Goto Definition' },
      { 'gr', lsp.references, desc = 'Goto References' },
      { 'K', lsp.hover, desc = 'Show help' },
      { '\\ca', lsp.code_action, desc = 'Code Action' },
    },

    opts = {
      setup = {
        ts_ls = {},
        clangd = {},
        jsonls = {},
        vimls = {},
        julials = {},
        taplo = {},

        ruff_lsp = {
          settings = { organizeImports = false },
          -- disable ruff as hover provider to avoid conflicts with pyright
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
        },

        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              hint = { enable = true },
              format = {
                enable = true,
                defaultConfig = { -- must be strings
                  indent_size = '2',
                  quote_style = 'single',
                  -- call_arg_parentheses = 'remove',
                  trailing_table_separator = 'smart',
                  align_continuous_assign_statement = 'false',
                  align_continuous_rect_table_field = 'false',
                  align_array_table = 'false',
                  space_before_inline_comment = '2',
                },
              },
            },
          },
        },

        pyright = {
          -- local capabilities = vim.lsp.protocol.make_client_capabilities()
          -- capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
          -- capabilities = capabilities,
          settings = { python = { analysis = { diagnosticMode = 'workspace' } } },
        },
      },
    },

    config = function(cfg)
      local lsp_status = require('lsp-status')
      lsp_status.register_progress()

      local lspconfig = require('lspconfig')
      for server, config in pairs(cfg.opts.setup) do
        lspconfig[server].setup(config)
      end

      vim.diagnostic.config({ virtual_text = false, signs = true, underline = true })

      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[b].filetype and vim.bo[b].buftype == '' then
          vim.api.nvim_buf_call(b, function()
            vim.api.nvim_exec_autocmds('FileType', { group = 'lspconfig', pattern = vim.bo.filetype })
          end)
        end
      end
    end,
  },
}
