local function set(opt, val)
  local name, scope = opt._info.name, opt._info.scope
  if scope then
    scope = scope == 'global' and 'opt_global' or 'opt_local'
  else
    scope = 'opt'
  end
  vim[scope][name] = val
end

local function parse(name, val)
  local setf, scope = set, 'opt'

  if type(val) == 'table' then
    val = vim.deepcopy(val)
    scope = (val.global == nil and 'opt') or (val.global and 'opt_global') or 'opt_local'

    if val.append or val.prepend or val.remove then
      local fn = (val.append and 'append') or (val.prepend and 'prepend') or 'remove'
      setf = function(_opt, _val)
        _opt[fn](_opt, _val)
      end
      val = val[fn]
    end
  end

  return { name = name, scope = scope, value = val, setf = setf }
end

local function save(o)
  local save = vim[o.scope][o.name]:get()
  o.setf(vim[o.scope][o.name], o.value)
  return { name = o.name, scope = o.scope, value = save }
end

local function restore(s)
  vim[s.scope][s.name] = s.value
end

---@generic F: function
---@param opts table<string, any>
---@param func `F`
---@return function
return function(opts, func)
  opts = vim.iter(opts):map(parse):totable()

  return function(...)
    local saved = vim.tbl_map(save, opts)
    local s, r = pcall(func, ...)
    vim.tbl_map(restore, saved)

    if not s then
      error(r, 0)
    end
    return r
  end
end
