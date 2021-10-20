function reload(name)
  -- not quite done
  print(string.format('Sourced: require("%s")', name))
  if package.loaded[name] then
    return require(name)
  end

  local orig = package.loaded[name]
  package.loaded[name] = nil
  -- if it's not a table, the module didn't return anything
  if type(orig) ~= "table" then
    return require(name)
  end

  -- If it is a table, remove all elements. Shallow copy new elements.
  for k in pairs(orig) do orig[k] = nil end
  for k, v in pairs(new) do orig[k] = v end

  -- Not sure why require would set a metatable but here we gooo. Also clears
  -- orig metatable
  setmetatable(orig, getmetatable(new))

  -- reinstate the original reference & return
  package.loaded[name] = orig
  return package.loaded[name]
end

function nmodule(name, package)
  local required, module = pcall(require, name)
  if not required then
    return nil
  end
  local module = require(name)

  if not module._NAME then
    module._NAME = name
    module._PACKAGE = package
    setmetatable(module, {
      __index = function(tbl, submodule)
      return nmodule(name .. '.' .. submodule, name)
    end })
  end
  return module
end


function P(v)
  print(vim.inspect(v))
  return v
end
