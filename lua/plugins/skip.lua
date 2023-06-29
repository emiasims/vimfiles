return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = { multi_window = false, mode = 'fuzzy' },
    modes = { char = { highlight = { backdrop = false } } },
  },
  config = function(cfg)
    local flash = require 'flash'
    flash.setup(cfg.opts)
    local map = require 'mapfun' 'm'
    map('s', flash.jump)
    map('S', flash.treesitter)
  end,
}
