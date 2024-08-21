---@type LazySpec
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
    vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
    local lspkind = require('lspkind')
    local cmp = require('cmp')

    ---@diagnostic disable: missing-fields
    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        -- Previously, this was <C-Space>. Added to integrate with copilot
        ['<Plug>(miaCmpSuggest)'] = cmp.mapping.complete(),
        -- ['<Cr>'] = cmp.mapping.confirm({ select = true }),
        ['<Plug>(miaCmpConfirm)'] = cmp.mapping.confirm({ select = true }),
      }),
      sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = 'nvim_lua' },
        {
          name = 'nvim_lsp',
          ---@param entry cmp.Entry
          ---@param ctx cmp.Context
          ---@return boolean
          entry_filter = function(entry, ctx)
            return not (
              ctx.filetype == 'python'
              and (entry.completion_item.insertText or entry.completion_item.label):match('^__.*__$')
              and ctx.cursor_before_line:sub(-1) ~= '_'
            )
          end,
        },
      }, {
        { name = 'buffer', keyword_length = 4, priority = -1 },
        { name = 'path' },
      }),

      formatting = {
        format = lspkind.cmp_format({
          mode = 'symbol_text',
          symbol_map = {
            Method = 'Ⲙ',
            Class = 'Ⲥ',
            Module = '',
            File = '', -- 
            Reference = '',
          },

          menu = {
            buffer = '[buf]',
            nvim_lsp = '[LSP]',
            nvim_lua = '[api]',
            path = '[path]',
            vsnip = '[snip]',
          },
        }),
      },
    })

    --cmp.setup.filetype({ 'python' }, {
    --  sorting = {
    --    ---@type cmp.Comparator[]
    --    comparators = {
    --      function(e1, e2)
    --        local t1 = (e1.completion_item.insertText or e1.completion_item.label):find('[^_]')
    --        local t2 = (e2.completion_item.insertText or e2.completion_item.label):find('[^_]')
    --        return t1 and t2 and t1 ~= t2 and (t1 < t2) or nil
    --      end,
    --      unpack(cmp.config.compare)
    --    },
    --  },
    --})
  end,
}
