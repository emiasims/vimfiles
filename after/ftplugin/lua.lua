vim.bo.tagfunc = 'v:lua.vim.lsp.tagfunc'
vim.bo.comments = ':---,:--'

mia.keymap.set({
  mode = 'i',
  { '<C-v><Esc>', '<lt>Esc>' },
  { '<C-v><Tab>', '<lt>Tab>' },
  { '<C-v><Cr>', '<lt>Cr>' },
  vim
    .iter(vim.fn.range(97, 122))
    :map(vim.fn.nr2char)
    :map(function(c)
      return { ('<C-v><C-%s>'):format(c), ('<lt>C-%s>'):format(c) }
    end)
    :totable(),
})

local ctxmap = require('ctxmap').keymap
ctxmap.set('n', '~', {
  { 'ts.is_node("false")', 'ciwtrue<Esc>`[' },
  { 'ts.is_node("true")', 'ciwfalse<Esc>`[' },
}, { buffer = true })
ctxmap.set('ia', 'as', { 'text.before("%-%-as$")', '[[@as]]<Left><Left>' }, { buffer = true })
