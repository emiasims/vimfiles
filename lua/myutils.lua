local M = {}

function myutils.reload(name)
  package.loaded[name] = nil
  tail = string.match(name, '[^.]+$')
  if _G[tail] ~= nil then
    _G[tail] = require(name)
  else
    require(name)
  end
end

return M
