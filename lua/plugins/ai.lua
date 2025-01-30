local pt = { provider = 'telescope' }
local ot = { opts = pt }
---@type LazySpec
return {
  'olimorris/codecompanion.nvim',
  cmd = { 'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat', 'CodeCompanionCmd' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  opts = {
    display = { action_palette = pt },
    strategies = {
      chat = {
        slash_commands = { buffer = ot, file = ot, symbols = ot, workspace = ot },
      },
    },
  },
}
