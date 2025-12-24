local M = {
  ---Shallow copy
  copy = function(t)
    local nt = {}
    for k, v in pairs(t) do
      nt[k] = v
    end
    return setmetatable(nt, getmetatable(t))
  end,

  keys = function(t)
    local ks = {}
    for k, v in pairs(t) do
      if k:sub(1, 1) ~= '_' then
        table.insert(ks, k)
      end
    end
    return ks
  end,

  pop = function(t, ...)
    local ret = {}
    for _, k in ipairs({ ... }) do
      table.insert(ret, t[k])
      t[k] = nil
    end
    return unpack(ret)
  end,

  rm = function(t, ...)
    for _, k in ipairs({ ... }) do
      t[k] = nil
    end
    return t
  end,

  select = function(t, ...)
    local nt = {}
    for _, k in ipairs({ ... }) do
      nt[k] = t[k]
    end
    return nt
  end,

  unique = function(array)
    return vim.tbl_keys(vim.iter(array):fold({}, function(t, v)
      t[v] = true
      return t
    end))
  end,

  splitarr = function(t)
    local arr = {}
    local dict = mia.tbl.copy(t)
    for i = 1, #dict do
      arr[i], dict[i] = dict[i], nil
    end
    return arr, dict
  end,

  ---@see table.sort
  ---@generic T
  ---@param t `T`
  ---@param cmp? fun(a: T, b: T): boolean
  ---@return T
  sort = function(t, cmp)
    t = mia.tbl.copy(t)
    table.sort(t, cmp)
    return t
  end,

  index = function(t, k)
    if not k and type(t) == 'table' then
      -- index a table with different keys
      return mia.partial(mia.tbl.index, t)
    elseif not k then
      -- index different tables with a single k
      return mia.partial(mia.tbl.index, nil, t)
    end
    -- index right now
    return t[k]
  end,

  insert = function(t, v)
    table.insert(t, v)
    return t
  end,

  isarr = function(t)
    return #t == vim.tbl_count(t)
  end,
}

function M.categorize(t, k, preserve_ix)
  local cats = {}
  local tinsert = not preserve_ix and M.isarr(t)
  for ix, v in pairs(t) do
    cats[v[k]] = cats[v[k]] or {}
    if tinsert then
      table.insert(cats[v[k]], ix)
    else
      cats[v[k]][ix] = v
    end
  end
  return cats
end

M.todict = M.rawset

function M.update(t1, t2, shallow)
  for k, v in pairs(t2) do
    if type(v) == 'table' and type(t1[k]) == 'table' and not shallow then
      M.update(t1[k], v)
    end
    t1[k] = v
  end
  return t1
end

return M
