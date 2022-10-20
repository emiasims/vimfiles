function mia.P(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify(vim.inspect(v))
  return v
end

function mia.T(...)
  local t1 = os.clock()
  select(1, ...)(select(2, ...))
  mia.P(('Runtime: %fs'):format(os.clock() - t1))
end

function mia.P1(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify_once(vim.inspect(v))
  return v
end

_G.P = mia.P
_G.T = mia.T
_G.P1 = mia.P1
