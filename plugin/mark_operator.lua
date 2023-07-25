nvim.create_augroup('mia-mark-operator', { clear = true })
nvim.create_autocmd('ModeChanged', {
  pattern = '*:no*',
  group = 'mia-mark-operator',
  desc = 'Mark `` with location before editing.',
  callback = function()
    local pos = nvim.win_get_cursor(0)
    nvim.buf_set_mark(0, '`', pos[1], pos[2], {})
  end,
})
