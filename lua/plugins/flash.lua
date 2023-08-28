return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = { multi_window = false, wrap = false },
    modes = {
      char = {
        highlight = { backdrop = false },
        keys = {},
        char_action = function()
          return { [','] = 'left', [';'] = 'right' }
        end,
      },
    },
  },

  config = function(cfg)
    local flash = require 'flash'
    flash.setup(cfg.opts)
    local map, oxmap = require 'mapfun' 'mO'
    local char = require 'flash.plugins.char'

    local jump = function(forward)
      local state = flash.jump { search = { forward = forward } }
      state.opts.highlight.backdrop = false
      state.opts.label.after = false
      char.state = state  -- HACK: get ,; to use their autocmd
      char.state._mia = true
    end

    local continue_jump = function(forward)
      if not char.state then
        return
      end
      if char.state._mia then
        char.state:hide()                         -- if repeating ,;
        char.state.opts.search.forward = forward  -- used in labeling
      end
      char.state:show()
      char.jumping = true
      char[forward and 'right' or 'left']()
      vim.schedule(function() char.jumping = false end)
    end

    local char_jump = function(key)
      if char.state then
        char.state:hide()  -- disables jumping again with the same key (i.e. 'f')
      end
      char.jumping = true
      char.jump(key)
      vim.schedule(function() char.jumping = false end)
    end

    map('s', function() jump(true) end)
    map('S', function() jump(false) end)
    map('<C-s>', flash.treesitter)
    oxmap('ys', flash.treesitter_search)
    map(';', function() continue_jump(true) end)
    map(',', function() continue_jump(false) end)

    map('f', function() char_jump 'f' end)
    map('F', function() char_jump 'F' end)
    map('t', function() char_jump 't' end)
    map('T', function() char_jump 'T' end)
  end,
}
