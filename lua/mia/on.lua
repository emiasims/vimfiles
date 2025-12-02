-- lazy require on index, on call
return {
  index = function(modname)
    return setmetatable({}, {
      __index = function(_, key)
        return require(modname)[key]
      end,
    })
  end,

  call = function(modname)
    return setmetatable({}, {
      __index = function(_, k)
        return function(...)
          return require(modname)[k](...)
        end
      end,
    })
  end,

  moduse = function(root, mod, init)
    return setmetatable(init or {}, {
      ---@param t table<string, any>
      ---@param k string
      __index = function(t, k)
        if not mod[k] then
          return
        end
        local name = string.format('%s.%s', root, k)
        t[k] = require(name)
        return t[k]
      end,
    })
  end,
}
