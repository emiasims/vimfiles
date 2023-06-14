return {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',

  dependencies = {
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-document-symbol',
    'tamago324/cmp-zsh',
    'onsails/lspkind.nvim',
  },

  config = function()
    vim.opt.completeopt = { "menu", "menuone", "noselect" }

    -- Don't show the dumb matching stuff.
    -- vim.opt.shortmess:append "c"

    local lspkind = require "lspkind"
    -- lspkind.init({})

    local cmp = require 'cmp'

    -- Global setup.
    cmp.setup({
      snippet = {
        expand = function(args)
          -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
          -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
          -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
      },
      window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        -- ['<Cr>'] = cmp.mapping.confirm({ select = true }),
        ['<Plug>(miaConfirmCmp)'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = 'nvim_lua' },
        { name = 'nvim_lsp' },
        -- { name = 'vsnip' }, -- For vsnip users.
        { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'snippy' }, -- For snippy users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
      }, {
        { name = 'buffer', keyword_length = 4 },
        { name = 'path' },
      }),

      formatting = {
        format = lspkind.cmp_format {
          mode = 'symbol_text',
          symbol_map = {
            -- Text = "て",
            Method = "Ⲙ",
            Class = "Ⲥ",
            Module = "",
            File = "", -- 
            Reference = "",
          },

          menu = {
            buffer = "[buf]",
            nvim_lsp = "[LSP]",
            nvim_lua = "[api]",
            path = "[path]",
            vsnip = "[snip]",
          },

        },
      },
    })

    -- -- `:` cmdline setup.
    -- cmp.setup.cmdline(':', {
      --   mapping = cmp.mapping.preset.cmdline(),
      --   sources = cmp.config.sources({
        --     { name = 'path' }
        --   }, {
          --     { name = 'cmdline' }
          --   })
          -- })
        end
      }
