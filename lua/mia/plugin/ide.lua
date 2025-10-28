local M = {}
M.path = vim.fs.joinpath(vim.fn.stdpath('state'), 'mia', 'ide_enabled')

M.enabled = function()
  return vim.uv.fs_stat(M.path) ~= nil
end

M.enable = function()
  if M.enabled() then
    mia.info('IDE features are already enabled.')
    return
  end

  vim.fn.mkdir(vim.fs.dirname(M.path), 'p')
  local f = io.open(M.path, 'w')
  if f then
    f:close()
    mia.info('IDE features have been enabled. Please restart Neovim.')
    return
  end

  mia.err('Failed to enable IDE features.')
end

M.disable = function()
  if not M.enabled() then
    mia.info('IDE features are already disabled.')
    return
  end

  os.remove(M.path)
  mia.info('IDE features have been disabled. Please restart Neovim.')
end

M.status = function()
  local status = M.enabled() and 'enabled' or 'disabled'
  mia.info('IDE features are currently ' .. status .. '.')
end

M.cmds = mia.commands({
  IDE = {
    nargs = 1,
    subcommands = {
      enable = M.enable,
      disable = M.disable,
      status = M.status,
    },
  },
})

return M
