return setmetatable({}, {
  __index = function(_, key)
    return vim.fn.getreg(key)
  end,
  __newindex = function(_, key, value)
    vim.fn.setreg(key, value)
  end,
})
