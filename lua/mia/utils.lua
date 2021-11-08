-- from plenary
function reload(module_name, starts_with_only)
  -- TODO: Might need to handle cpath / compiled lua packages? Not sure.
  local matcher
  if not starts_with_only then
    matcher = function(pack)
      return string.find(pack, module_name, 1, true)
    end
  else
    matcher = function(pack)
      return string.find(pack, '^' .. module_name)
    end
  end

  -- Handle impatient.nvim automatically.
  local luacache = (_G.__luacache or {}).cache

  for pack, _ in pairs(package.loaded) do
    if matcher(pack) then
      package.loaded[pack] = nil

      if luacache then
        luacache[pack] = nil
      end
      require(pack)
      print(string.format('Sourced: require("%s")', pack))
    end
  end
end

function require_by_reference(module, name)

  if name == nil and type(module) == "string" then
    module, name = {}, module
  end

  local submodule_cache = {}

  return setmetatable(module, {
    __index = function(_, key)
      -- check if key is in the table or if it's a submodule
      local m = require(name)
      if m[key] then
        return m[key]
      end

      local sm_name = name .. '.' .. key
      local success, submodule = pcall(require, sm_name)
      if not success then
        return nil
      end
      module[key] = require_by_reference(sm_name)
      return module[key]
    end,
  })
end

function P(v)
  print(vim.inspect(v))
  return v
end
