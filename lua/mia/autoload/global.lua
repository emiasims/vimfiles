local G = {}

local REQUIRE = require
local load_error = {}
local loading = {}
function G.require(module)
  table.insert(loading, module)
  local ok, mod = pcall(REQUIRE, module)
  table.remove(loading)
  if not ok then
    load_error[module] = load_error[module] or {}
    table.insert(load_error[module], mod)
    error(mod, 0)
  end
  return mod
end

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
  return G.require(module)
end

function G.put(vals)
  if type(vals) ~= 'table' then
    vals = { vals }
  end
  G.vim.api.nvim_put(vals, 'l', true, false)
end

G.util = G.require('mia.util')
G.keys = vim.tbl_keys
G.vals = vim.tbl_values

-- succsive calls? sfunc(keys, ipairs) -> this below
G.ikeys = function(tbl)
  return ipairs(vim.tbl_keys(tbl))
end

G.ivals = function(tbl)
  return ipairs(vim.tbl_keys(tbl))
end

for name, func in pairs(G) do
  _G[name] = func
end

return { G = G, loading = loading, load_error = load_error, require = REQUIRE }
