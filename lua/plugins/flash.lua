return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  opts = {
    search = { multi_window = false, wrap = false },
    label = { uppercase = false },
    modes = {
      search = { enabled = false },
      char = {
        highlight = { backdrop = false },
        -- keys = { 'f', 'F', 't', 'T' },
        char_actions = function()
          return { [';'] = 'right', [','] = 'left' }
        end,
        config = function(opts) opts.autohide = nvim.get_mode().mode:find 'no' end,
      },
    },
  },

  config = function(cfg)
    local flash = require 'flash'
    flash.setup(cfg.opts)
    local char = require 'flash.plugins.char'
    local Repeat = require 'flash.repeat'

    ------------------------------------------------------------------------------
    -- The goal of this config is to have sS behave like sneak + ahead of time  --
    -- labeling with smartcase, and ,; to repeat either sneak or charwise jumps --
    ------------------------------------------------------------------------------

    -- This was modeled off the default ,; so largely works the same with some extra bits
    local repeat_jump = function(opts)
      local state = char.state
      if not state then
        return
      end
      if not state._sneak_hide then
        state._sneak_hide = state.hide
        state.hide = function(self)
          self.opts.jump.jumplist = true
          self._sneak_hide(self)
        end
      end
      char.jumping = true
      char[opts.forward and 'right' or 'left']()
      state:show()
      state.opts.jump.jumplist = false
      vim.schedule(function() char.jumping = false end)
      return state
    end

    local sneak_formatter = function(opts)
      return {
        { opts.match.sneak_labels.char2, 'FlashMatch' },
        { opts.match.sneak_labels.label, 'FlashLabel' },
      }
    end

    local sneak_labeler = function(matches, state)
      if state._sneak_hide then
        -- repeat or using ,; ➜ skip it all
        return
      end
      local pat = state.pattern()
      local folds = {}
      local buf = nvim.win_get_buf(state.win)
      if #pat == 1 then
        state.sneak_labels = {}  -- cache
        -- sort via distance to cursor, from flash/labeler.lua
        -- Only need to do on 1, labels should be cached after
        local from = vim.api.nvim_win_get_cursor(state.win)
        table.sort(matches, function(a, b)
          local dfrom = from[1] * vim.go.columns + from[2]
          local da = a.pos[1] * vim.go.columns + a.pos[2]
          local db = b.pos[1] * vim.go.columns + b.pos[2]
          return math.abs(dfrom - da) < math.abs(dfrom - db)
        end)
      end
      for _, m in ipairs(matches) do
        if not m.fold or not folds[m.fold] then
          if m.fold then
            folds[m.fold] = true
          end
          -- get second char for caching ids
          local sr, sc = m.pos[1] - 1, m.pos[2] + 1
          local char2 = nvim.buf_get_text(buf, sr, sc, sr, sc + 1, {})[1]
          local lc = char2:lower()
          -- cache ids for labeling (needed for smartcase)
          if not state.sneak_labels[lc] then
            state.sneak_labels[lc] = { iter = vim.iter(state:labels()) }
          end
          local labels = state.sneak_labels[lc]

          local id = m.pos:id(m.win)
          labels[id] = labels[id] or labels.iter:next()
          -- ❤ is not really typable, so on first character make it not
          -- function. Since labels are reused but wanted to be displayed
          m.label = #pat == 1 and '❤' or labels[id]
          m.sneak_labels = { char2 = char2, label = labels[id] }
        end
      end
    end

    local sneak_action = function(state, c)
      -- On uppercase, go to END of match
      state.opts.jump.pos = c == c:lower() and 'start' or 'end'
      local ret = state:update { pattern = state.pattern:extend(c:lower()) }
      return not ret
    end

    -- 2 char jump, and jumplist behaves like sneak.vim
    local sneak = function(opts)
      if Repeat.is_repeat then
        return repeat_jump(opts):hide()
      end
      char.state = flash.jump {
        jump = { autojump = true },
        search = { mode = 'exact', max_length = 2, forward = opts.forward },
        label = { after = false, before = { 0, 1 }, format = sneak_formatter },
        labeler = sneak_labeler,
        -- actions is not documented, may not work forever
        actions = setmetatable({}, { __index = function() return sneak_action end }),
      }

      -- setup opts for ,;
      char.state.opts = vim.tbl_deep_extend('force', char.state.opts, {
        highlight = {                 -- fix highlights to match ;,
          backdrop = false,
          groups = { current = false, match = 'FlashLabel' },
        },
        search = { wrap = true },    -- highlights wrap on ,; (like fF)
        label = { before = false },  -- Don't want labels
        jump = { jumplist = false }, -- This call was added, but ...
      })
    end

    local map = require 'mapfun' 'm'
    map('s', function() sneak { forward = true } end)
    map('S', function() sneak { forward = false } end)
    map(';', function() repeat_jump { forward = true } end)
    map(',', function() repeat_jump { forward = false } end)
    map('<C-s>', flash.treesitter)
    map('ys', flash.treesitter_search)
    -- ftFT mapped by setup()

  end,
}
