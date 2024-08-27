---@type LazySpec
return {
  'wbthomason/lsp-status.nvim',
  'L3MON4D3/LuaSnip',
  'williamboman/mason-lspconfig.nvim',
  'jose-elias-alvarez/null-ls.nvim',
  'stevearc/conform.nvim',
  'Bilal2453/luvit-meta',
  { 'WhoIsSethDaniel/mason-tool-installer.nvim', event = 'VeryLazy' },

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
        -- TODO build a cache of paths and words

        -- It can also be a table with trigger words / mods
        -- Only load luvit types when the `vim.uv` word is found
        -- { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufNewFile', 'BufReadPost' },

    dependencies = { 'williamboman/mason.nvim' },

    keys = { 'gd', 'gr', 'K', '\\ca' },

    config = function()
      for _, keys in ipairs({
        { 'gd', vim.lsp.buf.definition, desc = 'Goto Definition' },
        { 'gr', vim.lsp.buf.references, desc = 'Goto References' },
        { 'K', vim.lsp.buf.hover, desc = 'Show help' },
        { '\\ca', vim.lsp.buf.code_action, desc = 'Code Action' },
      }) do
        vim.keymap.set('n', keys[1], keys[2], { silent = true, desc = keys.desc })
      end

      require('mason').setup({ log_level = vim.log.levels.DEBUG })

      require('mason-lspconfig').setup({
        ensure_installed = { 'basedpyright', 'clangd', 'lua_ls' },
      })

      require('mason-tool-installer').setup({
        ensure_installed = { 'debugpy', 'ruff-lsp', 'black', 'isort' },
      })

      local lsp_status = require('lsp-status')
      lsp_status.register_progress()

      -- require('neodev').setup()

      local lspconfig = require('lspconfig')

      lspconfig.lua_ls.setup({
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
      })

      lspconfig.ruff_lsp.setup({
        settings = { organizeImports = false },
        -- disable ruff as hover provider to avoid conflicts with pyright
        on_attach = function(client)
          client.server_capabilities.hoverProvider = false
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }

      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = { python = { analysis = { diagnosticMode = 'workspace' } } },
      })

      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'isort', 'black' },
          markdown = { 'inject' }, -- use ts langauge in markdown
        },
        formatters = {
          stylua = {
            cwd = require('conform.util').root_file({
              '.editorconfig',
              '.stylua.toml',
              'stylua.toml',
            }),
          },
        },
        -- format_on_save = { lsp_fallback = true },
      })

      lspconfig.tsserver.setup({})
      lspconfig.clangd.setup({})
      lspconfig.jsonls.setup({})
      lspconfig.vimls.setup({})
      lspconfig.julials.setup({})
      lspconfig.taplo.setup({})

      vim.diagnostic.config({ virtual_text = false, signs = true, underline = true })

      Format = function()
        local store_ei = vim.o.eventignore
        vim.o.eventignore = 'all'

        vim.schedule(function()
          vim.o.eventignore = store_ei
          vim.cmd.doautocmd('TextChanged')
        end)

        require('conform').formatexpr(
          vim.tbl_extend(
            'force',
            { lsp_fallback = true, timeout_ms = 3000 },
            vim.b.conform_formatexpr_opts or {}
          )
        )
      end
      vim.opt.formatexpr = [[v:lua.Format()]]
    end,
  },
}
