local function dotrepeat(rhs, lhs)
  if type(rhs) == 'string' then
    assert(lhs)
    return ('%s<Cmd>call repeat#set(%s, v:count)<Cr>'):format(rhs, lhs)
  end
  return function()
    vim.fn['repeat#set'](lhs, vim.v.count)
    return rhs()
  end
end

local function set_with_repeat(mode, lhs, rhs, opts)
  opts = opts or {}
  local add_repeat = opts.dotrepeat
  opts.dotrepeat = nil
  if add_repeat then
    rhs = dotrepeat(rhs, lhs)
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

local M = {
  c = function(...) set_with_repeat('c', ...) end,
  x = function(...) set_with_repeat('x', ...) end,
  n = function(...) set_with_repeat('n', ...) end,
  t = function(...) set_with_repeat('t', ...) end,
  o = function(...) set_with_repeat('o', ...) end,
  i = function(...) set_with_repeat('i', ...) end,
  s = function(...) set_with_repeat('s', ...) end,
  O = function(...) set_with_repeat({ 'o', 'x' }, ...) end,
  I = function(...) set_with_repeat({ 'i', 's' }, ...) end,
  m = function(...) set_with_repeat({ 'n', 'x', 'o' }, ...) end,
  dotrepeat = dotrepeat,
}

setmetatable(M, {
  __call = function(tbl, chars, opts)
    local funcs = {}
    for c in chars:gmatch '.' do
      local func = tbl[c]
      if opts then
        func = function(lhs, rhs, new_opts)
          if type(new_opts) == 'table' then
            opts = vim.tbl_extend('force', opts, new_opts)
          end
          tbl[c](lhs, rhs, opts)
        end
      end
      funcs[#funcs + 1] = func
    end
    return unpack(funcs)
  end,
})

return M
