vim.api.nvim_create_augroup('mia_textyank', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = "*",
  group = 'mia_textyank',
  desc = "Highlight yanked text briefly",
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 400 }
  end,
})
