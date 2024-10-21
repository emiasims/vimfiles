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

  M.util = require('mia.util')
  require('mia.core.config').setup()
  require('mia.core.package').setup()

  return setmetatable(M, {
    __index = function(_, name)
      if M.core_fn[name] then
        return require(M.core_fn[name])[name]
      end
      M[name] = M.util[name] or M.require(name)
      return M[name]
    end,
  })
end

function M.reset()
  for name, modname in pairs(M.plugin) do
    M[name] = package.loaded[modname] or nil
  end
  M.util = require('mia.util')
end

-- register autocmds
-- register cmds
-- inspect to see if necessary
-- update meta can do this

M.setup()

return M
