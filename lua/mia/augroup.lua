---@alias mia.aucmd string|function|aucmd.opts.create

---@param cmd mia.aucmd
---@return vim.api.keyset.create_autocmd
local function _normalize(cmd, opts)
  if type(cmd) == 'function' then
    cmd = { callback = cmd, group = mia.group }
  elseif type(cmd) == 'string' then
    cmd = { command = cmd, group = mia.group }
  end
  return vim.tbl_extend('force', cmd, opts or {})
end

---@param spec mia.augroup
---@param opts aucmd.opts.create
---@param event_override nil|string
local function _process_augroup(spec, opts, event_override)
  --- spec is table of events. value can be
  --- string, function, table[1], table.command, table.callback
  for event, cmd in pairs(spec) do
    if event == 'User' then
      local o = mia.tbl.copy(opts)
      for pat, _cmd in pairs(cmd) do
        o.pattern = pat
        cmd[pat] = _normalize(_cmd, o)
      end
      spec[event] = _process_augroup(cmd, opts, 'User')
    elseif type(cmd) == 'table' and cmd[1] then
      local _spec, _opts = mia.tbl.splitarr(cmd)
      spec[event] = _process_augroup(_spec, vim.tbl_extend('force', opts, _opts), event_override or event)
    else
      spec[event] = _normalize(cmd, opts)
      spec[event].id = vim.api.nvim_create_autocmd(event_override or event, spec[event])
    end
  end
  return spec
end

---@param group string|integer
---@param spec mia.augroup
return function(group, spec, clear)
  if type(group) == 'string' then
    group = vim.api.nvim_create_augroup('mia.' .. group, { clear = (clear ~= false) })
  end
  return _process_augroup(spec, { group = group })
end
