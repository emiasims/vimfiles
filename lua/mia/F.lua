local F = { partial = mia.partial }

function F.const(val, skip_copy)
  val = skip_copy and val or vim.deepcopy(val)
  return function()
    return val
  end
end

function F.eat(n, fn)
  if type(n) == 'function' then
    fn, n = n, 1
  end
  if n == 0 then
    return fn
  elseif n > 0 then
    -- eat up to N
    n = n + 1
    return function(...)
      return fn(select(n, ...))
    end
  end
  -- eat everything AFTER n
  n = -n
  return function(...)
    return fn(unpack(vim.iter({ ... }):slice(1, n):totable()))
  end
end

function F.call(fn, ...)
  if type(fn) ~= 'function' then
    return F.partial(F.call, nil, ...)
  end
  return fn(...)
end

function F.index(t, ...)
  if type(t) == 'table' then
    return F.partial(vim.tbl_get, t, ...)
  end
  return F.partial(vim.tbl_get, nil, ...)
end

function F.pass(n, fn)
  if type(n) == 'function' then
    fn, n = n, 2
  end
  return function(...)
    local values = { ... }
    local res = { fn(select(n, ...)) }
    for i = 1, #res do
      values[i + n - 1] = res[i]
    end
    return unpack(values)
  end
end

function F.ixeq(key, val)
  return function(t)
    return t[key] == val
  end
end

return F
