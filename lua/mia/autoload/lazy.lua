return setmetatable({}, {
  __index = function(t, modname)
    return setmetatable({}, {
      __index = function(_, key)
        t[modname] = mia[modname]
        return t[modname][key]
      end,

      __call = function(_, ...)
        return mia[modname](...)
      end,
    })
  end,
})
