local G = {}

-- local function patch_inspect()
--   -- debug gets weird with the nvim loader. So, reload it.
--   if mia.stash['vim.inspect.putval'] then
--     return
--   end

--   vim.inspect = dofile(vim.env.VIMRUNTIME .. '/lua/vim/inspect.lua')
--   package.loaded['vim.inspect'] = vim.inspect
--   local imt = mia.debug.get_upvalues(vim.inspect.inspect).Inspector_mt.__index
--   mia.stash['vim.inspect.putval'] = imt.putValue
--   local fmt = string.format

--   imt.putValue = function(self, v)
--     local buf = self.buf
--     local start = buf.n + 1

--     local ok, mt = pcall(getmetatable, v)

--     -- userdata with __tostring
--     if type(v) == 'userdata' and ok and mt and mt.__tostring then
--       buf.n = buf.n + 1
--       buf[buf.n] = fmt('<userdata %d %q>', self:getId(v), tostring(v):gsub('\n', ' '))
--     else
--       mia.stash['vim.inspect.putval'](self, v)
--     end

--     -- already processed with putval, but check if we want to add to it
--     if type(v) == 'table' and ok and mt and mt.__tostring then
--       local desc = tostring(v):gsub('\n', ' ')
--       if self.ids[v] then
--         buf[buf.n] = buf[buf.n]:gsub('>$', fmt(' %q>', desc))
--       else
--         local ws = buf[start + 1]:match('^%s*') or ''
--         table.insert(buf, start + 1, fmt('%s<tostring> = %q', ws, desc))
--         buf.n = buf.n + 1
--       end
--     end

--   end
-- end

function G.P(...)
  local v = select('#', ...) > 1 and { ... } or ...
  -- if not mia.stash['vim.inspect.putval'] then
  --   patch_inspect()
  -- end
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

G.keys = vim.tbl_keys
G.vals = vim.tbl_values

-- succsive calls? sfunc(keys, ipairs) -> this below
function G.ikeys(tbl)
  return ipairs(vim.tbl_keys(tbl))
end

function G.ivals(tbl)
  return ipairs(vim.tbl_keys(tbl))
end

for name, func in pairs(G) do
  _G[name] = func
end

return { G = G, loading = loading, load_error = load_error, require = REQUIRE }
