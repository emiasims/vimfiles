local nilfunc = function() end

---@enum (key) mia.log.level
local Messages = {
  debug = {},
  info = {},
  warn = {},
  error = {},
}

local M = {
  active = {},
}

local inspect = mia.partial(vim.inspect, nil, { newline = ' ', indent = '' })

---@param fmt string
---@vararg any
local formatf = function(fmt, ...)
  return mia.formatn(fmt, unpack(vim.tbl_map(inspect, { ... })))
end

---@type table<mia.log.level, mia.hlgroup>
local hls = {
  debug = 'Comment',
  info = 'Normal',
  warn = 'WarningMsg',
  error = 'ErrorMsg',
}

local _parse = function(level, scope, msg)
  if type(scope) == 'table' then
    scope = vim.iter(scope):flatten(math.huge):totable()
    scope[2] = vim.iter(scope):skip(1):join('][')
    scope = scope[1] .. '[' .. scope[2] .. ']'
  end
  return {
    { '[' .. level .. ']', hls[level] },
    { ' ' .. scope .. ': ', 'Identifier' },
    { inspect(msg) },
  }
end

local Log = {
  echo = function(level, scope, fmt, ...)
    local msg = _parse(level, scope, formatf(fmt, ...))
    local send = mia.partial(vim.api.nvim_echo, msg, true, {})
    if vim.in_fast_event() then
      vim.schedule(send)
    else
      send()
    end
  end,

  -- don't log until started or found an error
  file = function(level, scope, fmt, ...)
    error('nyi')
    -- local file = string.format('mia-%s.log', level)
    -- local f = io.open(file, 'a')
    -- f:write(string.format('[%s] %s: %s\n', level, name, msg))
    -- f:close()
  end,

  table = function(level, scope, fmt, ...)
  table.insert(Messages[level], { level = level, scope = scope, fmt = fmt, args = { ... } })
  end,
}
Log.notify = Log.echo

M.clear = function()
  Messages = {}
end

M.disable = function()
  Messages = {}
end

---Wraps with mia.partial to save the log settings
M.wrap = function(fn, ...)
  local active_logs = vim.deepcopy(M.active)
  fn = mia.partial(fn, ...)
  return function(...)
    local active = M.active
    M.active = active_logs
    fn(...)
    M.active = active
  end
end

---@param levels? mia.log.level|mia.log.level[] nil: all
M.show = function(levels)
  if not levels then
    levels = vim.tbl_keys(Messages)
  elseif type(levels) == 'string' then
    levels = { levels }
  end
  ---@cast levels mia.log.level[]
  local msgs = vim
    .iter(Messages)
    :map(function(level, msgs)
      return vim.list_contains(levels, level) and #msgs > 0 and msgs or nil
    end)
    :totable()

  local chunks = vim
    .iter(msgs)
    :flatten(1)
    :map(function(msg)
      return { _parse(msg.level, msg.scope, formatf(msg.fmt, unpack(msg.args))), { { '\n' } } }
    end)
    :flatten(2)
    :totable()

  vim.api.nvim_echo(chunks, true, {})
end

---@param level mia.log.level
---@param destination 'echo' | 'notify' | 'file' | 'table' | boolean | nil
M.activate = function(level, destination)
  if not destination then
    M.active[level] = nil
  else
    destination = destination == true and 'notify' or destination
    M.active[level] = function(name, fmt, ...)
      -- Log[destination](level, name, formatf(fmt, ...))
      Log[destination](level, name, fmt, ...)
    end
  end
end

M.activate('debug', 'table')
M.activate('info', 'table')
M.activate('warn', 'echo')
M.activate('error', 'echo')

-- info on by default
return setmetatable(M, {
  __newindex = function(_, level, destination)
    M.activate(level, destination)
  end,

  __index = function(_, level)
    return M.active[level] or nilfunc
  end,
})
