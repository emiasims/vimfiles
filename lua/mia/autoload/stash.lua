local M = { _store = {} }

-- reload guard
local st = package.loaded['mia.autoload.stash']
if st and type(st) == 'table' then
  M._store = rawget(st, '_store') or {}
end

return setmetatable(M, {
  __index = function(t, k)
    return t._store[k]
  end,
  __newindex = function(t, k, v)
    if not t._store[k] then
      t._store[k] = v
    end
  end,
  __call = function(t, k, v)
    t[k] = v
    return t[k]
  end,
})
