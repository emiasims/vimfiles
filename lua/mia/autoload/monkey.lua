local M = {}

M.patch = function(modname, patch)
  local mod = require(modname)
  if type(mod) ~= 'table' then
    error('module is not a table: ' .. modname)
  end

  for k, newv in pairs(patch) do
    local orig = mia.stash(modname .. '.' .. k, rawget(mod, k))

    if type(newv) == 'function' and type(orig) == 'function' then
      local env = mia.copy(getfenv(newv))
      env.super = env.super or orig
      setfenv(newv, env)
    end

    rawset(mod, k, newv)
    -- mod[k] = newv
  end
end

return M
