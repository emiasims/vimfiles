return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = { multi_window = false },
    modes = {
      char = {
        highlight = { backdrop = false },
        -- keys = { 'f', 'F', 't', 'T' },
        char_action = function(motion)
          -- not working?
          return {
            [','] = 'left',
            [';'] = 'right',
            [motion:upper()] = 'left',
            [motion:lower()] = 'right',
          }
        end,
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
    local char = require('flash.plugins.char')
    map('s', function()
      local state = flash.jump()
      state.opts.highlight.backdrop = false
      state.opts.label.after = false
      char.state = state  -- hacky to get ,; to use their autocmd
      char.state._mia = true
    end)
    map('S', flash.treesitter)
    oxmap('ys', flash.treesitter_search)

    local continue_jump = function(forward)
      return function()
        if char.state._mia then
          char.state:hide()  -- if repeating ,;
          char.state.opts.search.forward = forward  -- used in labeling
        end
        char.state:show()
        char.jumping = true
        char[forward and 'right' or 'left']()
        vim.schedule(function() char.jumping = false end)
      end
    end

    vim.keymap.set('n', ',', continue_jump(false))
    vim.keymap.set('n', ';', continue_jump(true))

  end,
}
