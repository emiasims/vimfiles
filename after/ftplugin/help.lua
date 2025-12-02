vim.wo.colorcolumn = '80'
vim.wo.foldmethod = 'expr'

if vim.bo.modifiable then
  vim.o.concealcursor = ''
else
  vim.keymap.set('n', 'q', '<Cmd>helpclose<Cr>', { buffer = true })
end

vim.keymap.set('n', 'K', 'K', { buffer = true })
