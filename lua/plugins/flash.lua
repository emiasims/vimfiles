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
    local s_state

    -- want the jumplist to act like sneak, and , and ; to work on both
    -- fFtT and sS.
    local jump = function(forward)
      char.jumping = true
      s_state = flash.jump { search = { forward = forward } }

      -- setup opts for ,;
      s_state.opts = vim.tbl_deep_extend('force', s_state.opts, {
        highlight = { backdrop = false },
        label = { after = false },
        jump = { jumplist = false },  -- first is added, stop on ,;
      })

      s_state.hide = function(self)
        -- but on hide, re-enable jumplist
        self.opts.jump.jumplist = true
        getmetatable(self).hide(self)
      end

      char.state = s_state  -- HACK: get ,; to use their autocmd
    end

    local continue_jump = function(forward)
      if not char.state then
        return
      end
      if char.state == s_state then
        getmetatable(s_state).hide(s_state)    -- fixes labeling
        s_state.opts.search.forward = forward  -- used in labeling on jump
      end
      char.state:show()
      char.jumping = true
      char[forward and 'right' or 'left']()
      char.state.opts.jump.jumplist = false
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
    map(';', function() continue_jump(true) end)
    map(',', function() continue_jump(false) end)

    vim.iter { 'f', 'F', 't', 'T' }:each(function(key)
      map(key, function() char_jump(key) end)
    end)

    map('<C-s>', flash.treesitter)
    oxmap('ys', flash.treesitter_search)
  end,
}
