local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.pack.add({ 'https://github.com/folke/lazy.nvim.git' }, { confirm = false })
  vim.fn.rename(vim.fn.stdpath('data') .. '/site/pack/core/opt/lazy.nvim', lazypath)
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { import = 'plugins' },
  change_detection = { notify = false },
  dev = { path = vim.fn.stdpath('config') .. '/mia_plugins' },
  profiling = { require = true },
  ui = { border = 'rounded' },
})
