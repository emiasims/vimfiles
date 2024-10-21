local F = {
  partial = mia.partial,
  const = mia.const,
}

F.eat = function(n, fn)
  if type(n) == 'function' then
    fn, n = n, 1
  end
  return function(...)
    local args = {}
    for i = n + 1, select('#', ...) do
      table.insert(args, select(i, ...))
    end
    return fn(unpack(args))
  end
end

F.call = function(fn, ...)
  if type(fn) ~= 'function' then
    return F.partial(F.call, nil, ...)
  end
  return fn(...)
end

F.index = mia.tbl.index

F.pass = function(n, fn)
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

F.ixeq = function(key, val)
  return function(t)
    return t[key] == val
  end
end

return F
