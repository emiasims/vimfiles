return setmetatable({
  -- _original = mia.loaded.og and mia.og._original or {},
}, {
  __index = function(t, k)
    return t._original[k]
  end,
  __newindex = function(t, k, v)
    if not t._original[k] then
      t._original[k] = v
    end
  end,
})
