local M = {
  misc = {
    ns = vim.api.nvim_create_namespace('mia-general'),
    gid = vim.api.nvim_create_augroup('mia-general', {}),
  },
}

M.get_visual = function(concat, allowed)
  allowed = allowed and ('[%s]'):match(allowed) or '[vV]'
  local mode = vim.fn.mode():match(allowed)
  if mode then
    vim.api.nvim_feedkeys('`<', 'nx', false)
  end
  local text
  mode = mode or vim.fn.visualmode()
  local open, close = vim.api.nvim_buf_get_mark(0, '<'), vim.api.nvim_buf_get_mark(0, '>')
  if mode == 'v' then
    text = vim.api.nvim_buf_get_text(0, open[1] - 1, open[2], close[1] - 1, close[2] + 1, {})
  elseif mode == 'V' then
    text = vim.api.nvim_buf_get_lines(0, open[1] - 1, close[1], true)
  elseif mode == '' then
    text = vim.tbl_map(function(line)
      return line:sub(open[2] + 1, close[2] + 1)
    end, vim.api.nvim_buf_get_lines(0, open[1] - 1, close[1], true))
  end
  if concat then
    return table.concat(text, concat)
  end
  return text
end

---@param name string
---@param cmd cmd.usercmd
---@param opts? cmd.create_opts
M.command = function(name, cmd, opts)
  vim.api.nvim_create_user_command(name, cmd, opts or {})
end

---@class cmd.fullusercmd: cmd.create_opts
---@field [1] string name
---@field [2] cmd.usercmd command

---@param ... cmd.fullusercmd
M.commands = function(...)
  for _, opts in ipairs({ ... }) do
    local name, cmd = opts[1], opts[2]
    opts[1], opts[2] = nil, nil
    M.command(name, cmd, opts)
  end
end

---@alias mia.aucmd string|function|vim.api.keyset.create_autocmd

---@param opts mia.aucmd
local function _normalize(opts)
  if type(opts) == 'function' then
    opts = { callback = opts, group = M.misc.gid }
  elseif type(opts) == 'string' then
    opts = { command = opts, group = M.misc.gid }
  end
  return opts
end

---@param event aucmd.event|aucmd.event[]
---@param opts mia.aucmd
M.autocmd = function(event, opts)
  return vim.api.nvim_create_autocmd(event, _normalize(opts))
end

---@param group string|number
---@param autocmds { [1]: aucmd.event, [2]: mia.aucmd }[]
---@param opts? { clear: boolean }
M.augroup = function(group, autocmds, opts)
  opts = opts or { clear = true }
  if type(group) == 'string' then
    group = vim.api.nvim_create_augroup(group, { clear = opts.clear })
  end
  for _, ac in ipairs(autocmds) do
    local _opts = _normalize(ac[2])
    _opts.group = group
    M.autocmd(ac[1], _opts)
  end
end

local Opt = {}
M.Opt = Opt

Opt.set = function(opt, val)
  local name, scope = opt._info.name, opt._info.scope
  if scope then
    scope = scope == 'global' and 'opt_global' or 'opt_local'
  else
    scope = 'opt'
  end
  vim[scope][name] = val
end

Opt.parse = function(name, val)
  local setf, scope = Opt.set, 'opt'

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

Opt.save = function(o)
  local save = vim[o.scope][o.name]:get()
  o.setf(vim[o.scope][o.name], o.value)
  return { name = o.name, scope = o.scope, value = save }
end

Opt.restore = function(s)
  vim[s.scope][s.name] = s.value
end

---@generic F: function
---@param opts table<string, any>
---@param func `F`
---@return F
M.restore_opt = function(opts, func)
  opts = vim.iter(opts):map(Opt.parse):totable()

  return function(...)
    local saved = vim.tbl_map(Opt.save, opts)
    local s, r = pcall(func, ...)
    vim.tbl_map(Opt.restore, saved)

    if not s then
      error(r, 0)
    end
    return r
  end
end

---@param t1 table
---@param t2 table
---@return table
M.tbl_update = function(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

---@generic F: function
---@param func `F`
---@return F
M.partial = function(func, ...)
  local args = { ... }
  local required = {}
  for i = 1, select('#', ...) do
    if args[i] == nil then
      table.insert(required, i)
    end
  end
  return function(...) -- 'b', 'c'
    local a = vim.deepcopy(args)
    local ix = 1
    for _, i in ipairs(required) do
      a[i] = select(ix, ...)
      ix = ix + 1
    end
    for i = ix, select('#', ...) do
      table.insert(a, select(i, ...))
    end

    return func(unpack(a))
  end
end

---@generic F: function
---@param func `F`
---@return F
M.defaults = function(func, ...)
  local args = { ... }
  return function(...)
    return func(unpack(vim.tbl_extend('force', args, { ... })))
  end
end

M.fast_notify = function(msg, level, opts, once)
  local notify = once and vim.notify_once or vim.notify
  if vim.in_fast_event() then
    vim.schedule(function()
      notify(msg, level, opts)
    end)
  else
    notify(msg, level, opts)
  end
end

M.info = M.partial(M.fast_notify, nil, vim.log.levels.INFO, {}, false)
M.warn = M.partial(M.fast_notify, nil, vim.log.levels.WARN, {}, false)
M.err = M.partial(M.fast_notify, nil, vim.log.levels.ERROR, {}, false)
M.info_once = M.partial(M.fast_notify, nil, vim.log.levels.INFO, {}, true)
M.warn_once = M.partial(M.fast_notify, nil, vim.log.levels.WARN, {}, true)
M.err_once = M.partial(M.fast_notify, nil, vim.log.levels.ERROR, {}, true)

M.echo = function(...)
  vim.api.nvim_echo({ ... }, true, {})
end

function M.fread(file)
  local fd = assert(io.open(file, 'r'))
  local data = fd:read('*a')
  fd:close()
  return data
end

function M.fwrite(file, contents)
  local fd = assert(io.open(file, 'w+'))
  fd:write(contents)
  fd:close()
end

return M
