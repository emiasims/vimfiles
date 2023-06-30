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
    local map, omap = require 'mapfun' 'mo'
    map('s', flash.jump)
    map('S', flash.treesitter)
    map('ys', function() flash.jump { search = { mode = 'fuzzy' } } end)

    -- label in operator mode with backdrop. see :h flash.nvim-flash.nvim-examples
    -- by default, the operator maps are set, but we override them here.
    local Config = require("flash.config")
    local Char = require("flash.plugins.char")
    for _, motion in ipairs({ "f", "t", "F", "T" }) do
      omap(motion, function()
        flash.jump(Config.get({
          mode = 'char',
          search = { mode = Char.mode(motion), max_length = 1 },
          highlight = { backdrop = true },
        }, Char.motions[motion]))
      end)
    end

    for _, motion in ipairs { 'f', 't', 'F', 'T' } do
      vim.keymap.set('o', motion, function()
        flash.char { motion = motion, highlight = { backdrop = true } }
      end)
    end
  end,
}
