function mia.P(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify(vim.inspect(v))
  return v
end


mia.T = setmetatable({}, {
  __call = function(self, ...)
    self[1](...)
  end,

  __index = function(_, key)
    if type(key) ~= 'number' then
      error 'Indexing T must be done with a number'
    end

    return function(...)
      local t1 = os.clock()
      for _ = 1, key do
        select(1, ...)(select(2, ...))
      end
      local end_t = os.clock() - t1
      print(('Runtime: %fs (%d times)'):format(end_t, key))
      if key > 1 then
        print(('         %fs / call'):format(end_t/ key))
      end
    end
  end
})


function mia.P1(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify_once(vim.inspect(v))
  return v
end

_G.P = mia.P
_G.T = mia.T
_G.P1 = mia.P1
