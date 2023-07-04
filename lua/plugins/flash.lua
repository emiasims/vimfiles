local last_flash, state, jumping
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
          last_flash = 'char'
        end,
      },
    },
  },

  config = function(cfg)
    local flash = require 'flash'
    flash.setup(cfg.opts)
    local map, oxmap = require 'mapfun' 'mO'
    map('s', function()
      last_flash = 'jump'
      flash.jump()
    end)
    map('S', flash.treesitter)
    oxmap('ys', flash.treesitter_search)

    -- get mapped functions for , and ;
    local c_backward = vim.fn.maparg(',', 'n', false, true).callback
    local c_forward = vim.fn.maparg(';', 'n', false, true).callback

    -- local state, jumping
    vim.api.nvim_create_autocmd({ 'BufLeave', 'CursorMoved', 'InsertEnter' }, {
      group = vim.api.nvim_create_augroup('mia_flash', { clear = true }),
      callback = function(event)
        if state and (event.event == "InsertEnter" or not jumping) then
          state:hide()
          state = nil
        end
      end,
    })

    local continue = function(forward)
      return function()
        if last_flash == 'jump' then
          -- state = Repeat.get_state('jump', { continue = true })
          state = require 'flash.repeat'._states['jump'] -- skip the 'show()'
          state.opts.highlight.backdrop = false
          state.opts.label.after = false
          state:show()
          jumping = true
          state:jump { count = vim.v.count1, forward = forward }
          vim.schedule(function() jumping = false end)
        else
          require 'flash.plugins.char'.state.opts.search.forward = true
          (forward and c_forward or c_backward)()
        end
      end
    end

    vim.keymap.set('n', ',', continue(false))
    vim.keymap.set('n', ';', continue(true))

  end,
}
