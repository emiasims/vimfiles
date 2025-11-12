local M = {}

function M.setup()
  setmetatable(M, nil)

  M.util = require('mia.core.util')
  require('mia.core.global')
  require('mia.core.config').setup()
  require('mia.core.package').setup()
  require('mia.core.ftplugin').setup()

  M.load = package.loaded['mia.core.package'].load
  M.require = package.loaded['mia.core.package'].require

  return setmetatable(M, {
    __index = function(t, name)
      if t.util[name] then
        return t.util[name]
      end
      t[name] = package.loaded['mia.' .. name] or M.require(name) or nil
      return t[name]
    end,
  })
end

return M.setup()
