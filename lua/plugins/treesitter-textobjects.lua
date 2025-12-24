--- @type LazySpec
return {
  'nvim-treesitter/nvim-treesitter-textobjects',
  -- event = 'VeryLazy',
  lazy = true, -- loaded by nvim-treesitter dependency
  branch = 'main',
  opts = {
    move = { set_jumps = true },
    select = {
      lookahead = true,
      selection_modes = {
        ['@function.outer'] = 'V',
        ['@function.inner'] = 'V',
        ['@class.outer'] = 'V',
        ['@class.inner'] = 'V',
      },
    },
  },
  config = function(_, opts)
    require('nvim-treesitter-textobjects').setup(opts)

    local swap = require('nvim-treesitter-textobjects.swap')
    local move = require('nvim-treesitter-textobjects.move')
    local sel = require('nvim-treesitter-textobjects.select')

    mia.keymap({
      { '<leader>a', function() swap.swap_next('@parameter.inner', 'textobjects') end },
      { '<leader>A', function() swap.swap_previous('@parameter.inner', 'textobjects') end },
    })

    mia.keymap({
      mode = { 'n', 'o', 'x' },
      { ']m', function() move.goto_next_start('@function.outer', 'textobjects') end },
      { '[m', function() move.goto_previous_start('@function.outer', 'textobjects') end },
      { ']M', function() move.goto_next_end('@function.outer', 'textobjects') end },
      { '[M', function() move.goto_previous_end('@function.outer', 'textobjects') end },
      { '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end },
      { ']]', function() move.goto_next_start('@class.outer', 'textobjects') end },
      { '[]', function() move.goto_next_end('@class.outer', 'textobjects') end },
    })

    mia.keymap({
      mode = { 'o', 'x' },
      { 'af', function() sel.select_textobject('@function.outer', 'textobjects') end },
      { 'if', function() sel.select_textobject('@function.inner', 'textobjects') end },
      { 'ac', function() sel.select_textobject('@class.outer', 'textobjects') end },
      { 'ic', function() sel.select_textobject('@class.inner', 'textobjects') end },
    })

    mia.keymap({
      'dsf',
      desc = 'Delete surrounding function',
      dotrepeat = true,
      function()
        local tsconfig = require('nvim-treesitter-textobjects.config')
        local cfg = tsconfig.select
        tsconfig.update({ select = { lookahead = false, lookbehind = false } })
        pcall(function()
          local tselect = require('nvim-treesitter-textobjects.select')
          tselect.select_textobject('@parameter.inner', 'textobjects')
          -- h moves on to the parens, if the arg is a function we might just
          -- select that function instead. So that fixes it most of the time
          vim.api.nvim_feedkeys('yh', 'nx', true)
          tselect.select_textobject('@call.outer', 'textobjects')
          vim.api.nvim_feedkeys('p', 'nx', true)
        end)
        tsconfig.update({ select = cfg })
      end,
    })
  end,
}
