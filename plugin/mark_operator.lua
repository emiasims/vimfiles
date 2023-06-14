vim.api.nvim_create_augroup('mia-mark-operator', { clear = true })
vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = '*:no*',
  group = 'mia-mark-operator',
  desc = 'Mark `` with location before editing.',
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_mark(0, '`', pos[1], pos[2], {})
  end,
})
