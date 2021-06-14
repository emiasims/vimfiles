local M = {}

function M.reload(name, filename)
  package.loaded[name] = nil
  tail = string.match(name, '[^.]+$')
  if _G[tail] ~= nil then
    _G[tail] = require(name)
    msg = string.format("Sourced %s: %s = require('%s')", filename, tail, name)
  else
    require(name)
    msg = string.format("Sourced %s: require('%s')", filename, name)
  end
  return msg
end

-- global
function P(v)
  print(vim.inspect(v))
  return v
end

return M
