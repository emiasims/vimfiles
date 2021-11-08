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
    ["<Tab>"] = cmp.mapping.confirm({select = true}),

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
    ghost_text = true,
  },

}

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- from nvim-lsp-install default dir
-- local lsp_dir =  function(lsp) vim.fn.stdpath "data" .. "lsp_servers"
-- require('lspconfig')['pyright'].setup { capabilities = capabilities }
-- require('lspconfig')['sumneko_lua'].setup { capabilities = capabilities, cmd = { '/home/elsimmons/.local/share/nvim/lsp_servers/sumneko_lua/extension/server/bin/Linux/lua-language-server' } }
-- require('lspconfig')[''].setup {
--   capabilities = capabilities
-- }
