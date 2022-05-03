vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Don't show the dumb matching stuff.
-- vim.opt.shortmess:append "c"

local lspkind = require "lspkind"
lspkind.init()

local cmp = require "cmp"

cmp.setup {
  mapping = {
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.close(),
    ["<Plug>(miaConfirmCmp)"] = cmp.mapping.confirm({select = true}),

  },

  sources = {
    { name = "nvim_lua" },
    { name = "nvim_lsp" },
    { name = "path" },
    { name = "vsnip" },
    { name = "buffer", keyword_length = 4 },
  },

  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)      -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body)  -- For `luasnip` users.
      -- vim.fn["UltiSnips#Anon"](args.body)       -- For `ultisnips` users.
      -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
    end,
  },

  formatting = {
    -- Youtube: How to set up nice formatting for your sources.
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[LSP]",
        nvim_lua = "[api]",
        path = "[path]",
        vsnip = "[snip]",
      },
    },
  },

  experimental = {
    native_menu = false,
  },
  -- ghost_text = true,

}
