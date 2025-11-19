local M = {
  ns = vim.api.nvim_create_namespace('mia-general'),
  group = vim.api.nvim_create_augroup('mia-general', {}),
}

local D
D = {  -- debug tools
  scriptname = function()
    return debug.getinfo(2, 'S').source:sub(2)
  end,

  ---@return fun(): (integer, string, any)
  iupvalues = function(fn)
    local i = 0
    return function()
      i = i + 1
      return i, debug.getupvalue(fn, i)
    end
  end,

  ---@return fun(): (string, any)
  pupvalues = function(fn)
    local i = 0
    return function()
      i = i + 1
      return debug.getupvalue(fn, i)
    end
  end,

  get_upvalues = function(fn)
    return vim.iter(D.pupvalues(fn)):fold({}, rawset)
  end,

  get_upvalue = function(name, fn)
    for k, v in D.pupvalues(fn) do
      if k == name then
        return v
      end
    end
  end,

  clone_fn = function(fn)
    local dumped = string.dump(fn)
    local cloned = loadstring(dumped) --[[@as function]]

    for i in D.iupvalues(fn) do
      debug.upvaluejoin(cloned, i, fn, i)
    end

    return cloned
  end,
}
M.debug = D

function M.get_visual(concat, allowed)
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

function M.copy(val)
  return type(val) == 'table' and mia.tbl.copy(val) or val
end

---@param cmds mia.commands
function M.commands(cmds)
  vim.iter(cmds):each(mia.command)
  return cmds
end

---@param event aucmd.event|aucmd.event[]
---@param opts mia.aucmd
function M.autocmd(event, opts)
  mia.augroup(opts.group or M.group, { [event] = opts }, false)
end

-- M.true = setmetatable({}, {
--   __eq = function(a, b)
--     return 
--   end,
-- })

--- Text
---@generic F: function
---@param func F
---@return F
function M.partial(func, ...)
  local args = { ... }
  if #vim.tbl_keys(args) == 0 then
    return func
  end
  local required = {}
  for i = 1, select('#', ...) do
    if args[i] == nil then
      table.insert(required, i)
    end
  end
  return function(...) -- 'b', 'c'
    local a = vim.deepcopy(args)
    for callix, argix in ipairs(required) do
      a[argix] = select(callix, ...)
    end
    vim.list_extend(a, { select(#required + 1, ...) })
    return func(unpack(a))

    -- return func(unpack(a), select(#a, ...))
  end
end

function M.const(val, skip_copy)
  val = skip_copy and val or vim.deepcopy(val)
  return function()
    return val
  end
end

function M.notify(level, opts, once, msg, ...)
  local notify = once and vim.notify_once or vim.notify
  if select('#', ...) > 0 then
    msg = msg:format(...)
  elseif type(msg) ~= 'string' then
    msg = vim.inspect(msg)
  end
  if vim.in_fast_event() then
    vim.schedule(function()
      notify(msg, level, opts)
    end)
  else
    notify(msg, level, opts)
  end
end

M.info = M.partial(M.notify, vim.log.levels.INFO, {}, false, nil)
M.warn = M.partial(M.notify, vim.log.levels.WARN, {}, false, nil)
M.err = M.partial(M.notify, vim.log.levels.ERROR, {}, false, nil)
M.info_once = M.partial(M.notify, vim.log.levels.INFO, {}, true, nil)
M.warn_once = M.partial(M.notify, vim.log.levels.WARN, {}, true, nil)
M.err_once = M.partial(M.notify, vim.log.levels.ERROR, {}, true, nil)

---add %N parsing to string.format. %N will be replaced with the Nth argument
function M.formatn(fmt, ...)
  local fargs = { ... }
  return fmt
    :gsub('%%%d+', function(n)
      local arg = tonumber(n:sub(2)) --[[@as integer]]
      return vim.pesc(('%s'):format(select(arg, unpack(fargs))))
    end)
    :format(...)
end

function M.yank(reg, value)
  if not value then
    reg, value = '', reg
  end
  vim.fn.setreg(reg, value)
end

function M.put(reg)
  return vim.fn.getreg(reg)
end

M.reg = setmetatable({}, {
  __newindex = function(_, reg, value)
    if type(value) == 'table' then
      value = vim.inspect(value)
    end
    M.yank(reg, value)
  end,
  __index = function(_, reg)
    return vim.fn.getreg(reg)
  end,
})

return M
