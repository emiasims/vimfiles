---@type LazySpec
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua', -- only load on lua files
    opts = {
      library = {
        'mia',
        'lazy.nvim',
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    enabled = mia.ide.enabled,
    event = 'VeryLazy',
    dependencies = { 'mason.nvim', 'wbthomason/lsp-status.nvim' },

    keys = {
      { 'gd', '<Cmd>lua vim.lsp.buf.definition()<Cr>', desc = 'Goto Definition' },
      { 'gr', '<Cmd>lua vim.lsp.buf.references()<Cr>', desc = 'Goto References' },
      { 'K', '<Cmd>lua vim.lsp.buf.hover()<Cr>', desc = 'Show help' },
      { '\\ca', '<Cmd>lua vim.lsp.buf.code_action()<Cr>', desc = 'Code Action' },
    },

    opts = {
      setup = {
        ts_ls = true,
        clangd = true,
        jsonls = true,
        vimls = true,
        julials = true,
        taplo = true,
        -- emmylua_ls = true,
        lua_ls = {
          cmd = { 'lua-language-server' },
          filetypes = { 'lua' },
          root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
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

    config = function(_, opts)
      local lsp_status = require('lsp-status')
      lsp_status.register_progress()

      vim.diagnostic.config({ virtual_text = false, signs = true, underline = true })
      for server, config in pairs(opts.setup) do
        if type(config) == 'table' then
          vim.lsp.config(server, config)
        end
      end
      vim.lsp.enable(vim.tbl_keys(opts.setup))
    end,
  },
}
