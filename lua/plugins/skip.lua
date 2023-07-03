return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = { multi_window = false },
    modes = {
      char = {
      highlight = { backdrop = false },
        config = function(opts)
          opts.autohide = vim.fn.mode(true):find 'no' and vim.v.operator == 'y'
          if vim.v.count == 0 and vim.fn.mode(true):find 'o' then
            opts.jump_labels = true
            opts.highlight.backdrop = true
          end
        end,
      },
    },
  },

  config = function(cfg)
    local flash = require 'flash'
    flash.setup(cfg.opts)
    local map, oxmap = require 'mapfun' 'mO'
    map('s', flash.jump)
    map('S', flash.treesitter)
    oxmap('ys', flash.treesitter_search)
  end,
}
