local M = {
  core_fn = {
    load = 'mia.core.package',
    require = 'mia.core.package',
    on_reload = 'mia.core.config',
  },
}

function M.setup()
  vim.loader.enable()
  setmetatable(M, nil)

  M.util = require('mia.core.util')
  require('mia.core.global')
  require('mia.core.config').setup()
  require('mia.core.package').setup()
  require('mia.core.ftplugin').setup()

  return setmetatable(M, {
    __index = function(_, name)
      if M.core_fn[name] then
        return require(M.core_fn[name])[name]
      end
      return M.util[name] or package.loaded['mia.' .. name] or M.require(name)
    end,
    __vim_complete = function()
      return M.require('package').packages
    end,
  })
end

-- register autocmds
-- register cmds
-- inspect to see if necessary
-- update meta can do this

return M.setup()
