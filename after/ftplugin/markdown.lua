vim
  .iter({
    spell = true,
    shiftwidth = 2,
    softtabstop = 1,
    autoindent = true,
    textwidth = 0,
    formatoptions = '12crqno',
    comments = { 'n:>', 'b:*', 'b:-' },
    wrap = true,
    conceallevel = 2,
    breakindent = true,
    breakindentopt = { 'min:50', 'shift:2' },
    commentstring = '<!--%s-->',

    formatlistpat = table.concat({
      '^\\s*',       -- Optional leading whitespace
      '[',           -- Start character class
      '\\[({]\\?',   -- |  Optionally match opening punctuation
      '\\(',         -- |  Start group
      '[0-9]\\+',    -- |  |  Numbers
      '\\\\|',       -- |  |  or
      '[a-zA-Z]\\+', -- |  |  Letters
      '\\)',         -- |  End group
      '[\\]:.)}',    -- |  Closing punctuation
      ']',           -- End character class
      '\\s\\+',      -- One or more spaces
      '\\\\|',       -- or
      '^\\s*[-+*]\\s\\+', -- Bullet points
      '\\%([.\\]\\s\\+\\)\\?', -- Optional checkbox
    }),
  })
  :each(function(k, v)
    vim.opt_local[k] = v
  end)

mia.keymap({
  { 'gO', '<Cmd>lvimgrep /^#/ %|lopen<Cr>', silent = true },
  { '<leader>J', 'vipJgqip' },
  {
    '<leader>K',
    'vipJ:let store_reg = @/ \\| .s/[.!?]\\zs\\s\\+\\ze\\u/\\r/geI \\| let @/ = store_reg \\| unl store_reg<CR>',
  },
})
