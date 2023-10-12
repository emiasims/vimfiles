---@type LazySpec
return {
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {
      search = { multi_window = false, wrap = false },
      label = { uppercase = false },
      modes = {
        search = { enabled = false },
        char = {
          highlight = { backdrop = false },
          char_actions = function()
            return { [';'] = 'right', [','] = 'left' }
          end,
          config = function(opts)
            opts.autohide = nvim.get_mode().mode:find 'no'
          end,
        },
      },
    },
    keys = {
      'f', 'F', 't', 'T', ',', ';',
      ---@diagnostic disable
      { '<C-s>', function() require 'flash'.treesitter() end, mode = { 'n', 'x', 'o' } },
      { 'ys', function() require 'flash'.treesitter_search() end, mode = { 'n', 'x', 'o' } },
      ---@diagnostic enable
    },
  },
  {
    'milisims/flashy-sneakers.nvim',
    dev = true,
    opts = {
      jump = { autojump = true },
      again = { search = { wrap = true } },  -- fix wrap
    },
    dependencies = 'flash.nvim',
  },
}
