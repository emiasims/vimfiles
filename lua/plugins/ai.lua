local pt = { provider = 'snacks' }
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
  keys = { { '<C-c>', '<Plug>(cc-stop)', ft = 'codecompanion' } },
  --   { '<C-g><C-g>', '<Plug>(cc-send)', remap = true, mode = 'i', ft = 'codecompanion' },
  --   { '<C-g>', '<Plug>(cc-send)', remap = true, ft = 'codecompanion' },
  --   { ']c', '<Plug>(cc-next-chat)', remap = true, ft = 'codecompanion' },
  --   { '[c', '<Plug>(cc-prev-chat)', remap = true, ft = 'codecompanion' },
  -- },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    adapters = {
      think = function()
        return require('codecompanion.adapters').extend('gemini', {
          name = 'Gemini Thinking',
          schema = { model = { default = 'gemini-2.0-flash-thinking-exp' } },
        })
      end,
      flash = function()
        return require('codecompanion.adapters').extend('gemini', {
          schema = { model = { default = 'gemini-2.0-flash-lite-preview' } },
        })
      end,
      pro = function()
        return require('codecompanion.adapters').extend('gemini', {
          name = 'Gemini Pro',
          schema = { model = { default = 'gemini-2.0-pro-exp' } },
          -- schema = { model = { default = 'gemini-2.0-pro-exp-02-05' } },
        })
      end,
    },
    -- display = { action_palette = pt },
    strategies = {
      chat = {
        slash_commands = { buffer = ot, file = ot, symbols = ot, workspace = ot },
        adapter = 'gemini',

        keymaps = {
          completion = { modes = { i = '<Plug>(disabled)' } },
          send = { modes = { n = '<C-g>', i = '<C-g><C-g>' } },
          close = { modes = { n = 'ZZ', i = '<Plug>(disabled)' } },
          next_chat = { modes = { n = ']c' } },
          previous_chat = { modes = { n = '[c' } },
          stop = { modes = { n = '<Plug>(cc-stop)' } },
          options = { modes = { n = 'g?' } }
        },
      },
    },
  },
}
