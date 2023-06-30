return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = { multi_window = false },
    modes = { char = { highlight = { backdrop = false } } },
  },
  config = function(cfg)
    local flash = require 'flash'
    flash.setup(cfg.opts)
    local map = require 'mapfun' 'm'
    map('s', flash.jump)
    map('S', flash.treesitter)
    map('ys', function() flash.jump { search = { mode = 'fuzzy' } } end)
  end,
}
