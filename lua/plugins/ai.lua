local pt = { provider = 'telescope' }
local ot = { opts = pt }
vim.env.GEMINI_API_KEY = mia.secrets.gemini()
---@type LazySpec
return {
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanionCmd' },
  ctx = {
    {
      mode = 'ca',
      ctx = 'builtin.cmd_start',
      each = {
        cc = 'CodeCompanion',
        cca = 'CodeCompanionActions',
        cch = 'CodeCompanionChat',
        ccc = 'CodeCompanionCmd',
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    display = { action_palette = pt },
    strategies = {
      chat = {
        slash_commands = { buffer = ot, file = ot, symbols = ot, workspace = ot },

        keymaps = {
          completion = { modes = { i = '<Plug>(disabled)' } },
          send = { modes = { n = '<C-g>', i = '<C-g><C-g>' } },
          close = { modes = { n = '<Plug>(disabled)', i = '<Plug>(disabled)' } },
          next_chat = { modes = { n = ']c' } },
          previous_chat = { modes = { n = '[c' } },
        },
      },
    },
  },
}
