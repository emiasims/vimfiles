return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = { multi_window = false },
    highlight = { label = { current = true } },
  },
  config = function(opts)
    local flash = require 'flash'
    flash.setup(opts)
    local map = require 'mapfun' 'm'
    map('s', flash.jump)
    map('S', flash.treesitter)
    map('ys', function() flash.jump { search = { mode = 'fuzzy' } } end)
  end ,
}
