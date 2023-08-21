---@diagnostic disable: duplicate-set-field
function _G.P(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify(vim.inspect(v))
  return v
end

_G.T = setmetatable({}, {
  __call = function(self, ...)
    self[1](...)
  end,

  __index = function(_, key)
    if type(key) ~= 'number' then
      error 'Indexing T must be done with a number'
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

function _G.P1(...)
  local v = select(2, ...) and { ... } or ...
  vim.notify_once(vim.inspect(v))
  return v
end

_G.nvim = vim.iter(vim.api):fold({}, function(t, k, v)
  t[k:sub(6)] = v  -- removes 'nvim_' ➜ nvim.buf_call
  return t
end)

local og = require 'mia.og'
og.system = og.system or vim.system
-- basic workaround for me for https://github.com/neovim/neovim/issues/24567
vim.system = function(cmd, opts, on_exit)
  if type(cmd) == 'table' and cmd[1] == 'xdg-open' then
    local jopts = opts or vim.empty_dict()
    jopts.on_exit = on_exit
    vim.fn.jobstart(cmd, jopts)
    cmd = { 'true' }
  end
  return og.system(cmd, opts, on_exit)
end
