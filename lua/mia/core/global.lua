local G = {}

--- Print inspected values
---@param ... any
function G.P(...)
  local v = select('#', ...) > 1 and { ... } or ...
  print(vim.inspect(v))
  return ...
end

--- Notify inspected values
---@param ... any
function G.N(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify(vim.inspect(v))
  return ...
end

G.T = setmetatable({}, {
  __call = function(self, ...)
    self[1](...)
  end,

  __index = function(_, key)
    if type(key) ~= 'number' then
      error('Indexing T must be done with a number')
    end

    return function(...)
      vim.uv.update_time()
      local t1 = vim.uv.now()
      for _ = 1, key do
        select(1, ...)(select(2, ...))
      end
      vim.uv.update_time()
      local dt = (vim.uv.now() - t1)
      local unit = 'ms'
      if dt > 100 then
        dt = dt / 1000
        unit = 's'
      end
      print(('Runtime: %g%s (%d times)'):format(dt, unit, key))
      if key > 1 then
        dt = dt / key
        if unit == 's' and dt <= 100 then
          unit = 'ms'
          dt = dt * 1000
        end
        print(('         %g%s / call'):format(dt, unit))
      end
    end
  end,
})

--- Print inspected values once
---@param ... any
function G.P1(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify_once(vim.inspect(v))
  return v
end

function G.put(vals)
  if type(vals) ~= 'table' then
    vals = { vals }
  end
  G.vim.api.nvim_put(vals, 'l', true, false)
end

G.keys = vim.tbl_keys
G.vals = vim.tbl_values

for name, func in pairs(G) do
  _G[name] = func
end

return G
