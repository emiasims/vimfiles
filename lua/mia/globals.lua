local G = {}

function G.P(...)
  local v = select(2, ...) and { ... } or ...
  print(vim.inspect(v))
  return ...
end

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
      local t1 = os.clock()
      for _ = 1, key do
        select(1, ...)(select(2, ...))
      end
      local end_t = os.clock() - t1
      print(('Runtime: %fs (%d times)'):format(end_t, key))
      if key > 1 then
        print(('         %fs / call'):format(end_t / key))
      end
    end
  end,
})

---@param ... any
---@return any
function G.P1(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify_once(vim.inspect(v))
  return v
end

function G.rerequire(module)
  package.loaded[module] = nil
  return require(module)
end

function G.put(vals)
  if type(vals) ~= 'table' then
    vals = { vals }
  end
  G.vim.api.nvim_put(vals, 'l', true, false)
end

local function setup()
  _G.util = require('mia.util')
  _G.keys = vim.tbl_keys
  _G.vals = vim.tbl_values

  for name, func in pairs(G) do
    _G[name] = func
  end
end

return { G = G, setup = setup }
