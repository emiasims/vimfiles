vim.cmd.packadd('ctxmap.nvim')
-- require('packs.ctxmap') -- TODO

local packs = vim
  .iter(vim.api.nvim_get_runtime_file('lua/packs/*.lua', true))
  :map(function(f) return f:match('/([^/.]+)%.lua') end)
  :map(function(m) return 'packs.' .. m end)

local load = function() packs:each(require) end

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function() vim.defer_fn(load, 1) end,
})
