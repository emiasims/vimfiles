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

    local function ts_map(mode, lhs, fn, query, group, km_opts)
      vim.keymap.set(mode, lhs, function()
        return fn(query, group or 'textobjects')
      end, km_opts)
    end

    local swap = require('nvim-treesitter-textobjects.swap')
    ts_map('n', '<leader>a', swap.swap_next, '@parameter.inner')
    ts_map('n', '<leader>A', swap.swap_previous, '@parameter.inner')

    local move = require('nvim-treesitter-textobjects.move')
    ts_map({ 'n', 'o', 'x' }, ']m', move.goto_next_start, '@function.outer')
    ts_map({ 'n', 'o', 'x' }, '[m', move.goto_previous_start, '@function.outer')
    ts_map({ 'n', 'o', 'x' }, ']M', move.goto_next_end, '@function.outer')
    ts_map({ 'n', 'o', 'x' }, '[M', move.goto_previous_end, '@function.outer')
    ts_map({ 'n', 'o', 'x' }, '[[', move.goto_previous_start, '@class.outer')
    ts_map({ 'n', 'o', 'x' }, ']]', move.goto_next_start, '@class.outer')
    ts_map({ 'n', 'o', 'x' }, '[]', move.goto_next_end, '@class.outer')

    local sel = require('nvim-treesitter-textobjects.select')
    ts_map({ 'o', 'x' }, 'af', sel.select_textobject, '@function.outer')
    ts_map({ 'o', 'x' }, 'if', sel.select_textobject, '@function.inner')
    ts_map({ 'o', 'x' }, 'ac', sel.select_textobject, '@class.outer')
    ts_map({ 'o', 'x' }, 'ic', sel.select_textobject, '@class.inner')
  end,
}
