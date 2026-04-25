--- Relevant _meta types
--- @see cmd.callback.arg command callback argument          mia.command.create
--- @see cmd.opts.create vim user-command creation options   mia.command.create
--- @see cmd.complete.spec completion specification          mia.command.wrap_complete
--- @see mia.command parsed command object                   mia.command.parse
--- @see mia.command.def command definition spec             mia.command.create
--- @see mia.cmd.callback.arg extended callback argument     mia.command.wrap_cmd
--- @see mia.commands table of command definitions           mia.lua

---@alias cmd.callback fun(cmd: cmd.callback.arg)
---@alias cmd.complete fun(ArgLead: string, CmdLine: string, CursorPos: integer): string[]
---@alias cmd.preview fun(opts: cmd.callback.arg, ns: integer, buf: integer): 0|1|2

---@alias mia.command.subcommands table<string, mia.command.create>|fun(): table<string, mia.command.create>
---@alias mia.command.create mia.command|cmd.opts.create|cmd.callback|string

---@type table<string, mia.command>
local Commands = setmetatable({}, { __mode = 'v' })

-- TODO buffer or global dictionary?

local function get_cmd(name) return name and Commands[name] or Commands end

local function wrap_cmd(cb, bang)
  if not cb or type(cb) == 'string' then
    return cb
  end

  return function(cmd)
    if type(cmd) == 'string' then
      cmd = vim.api.nvim_parse_cmd(cmd, {})
    end
    cmd.cmdline = true
    if cmd.bang and bang then
      bang(cmd)
    else
      cb(cmd)
    end
  end
end

local AllowedReplacements = {
  ['<line1>'] = mia.F.index('line1'),
  ['<line2>'] = mia.F.index('line2'),
  ['<count>'] = mia.F.index('count'),
  ['<range>'] = mia.F.index('range'),
  ['<args>'] = mia.F.index('args'),
  ['<mods>'] = mia.F.index('mods'),
  ['<f-args>'] = mia.F.index('fargs'),

  -- ['<q-mods>'] = function(o) end,
  -- ['<q-args>'] = function(o) end,
  ['<lt>'] = mia.F.const('<'),
  ['<bang>'] = function(o) return o.bang and '!' or '' end,
}

---@param command string
local function parse_string_cmd(command)
  local replacements = {}
  for k, v in pairs(AllowedReplacements) do
    if command:find(k) then
      replacements[k] = v
    end
  end

  ---@type cmd.callback
  return function(opts)
    local cmd = command
    for k, v in pairs(replacements) do
      cmd = cmd:gsub(k, v(opts))
    end

    vim.api.nvim_command(cmd)
  end
end

---@param value string|string[]|fun(): string[]|boolean
---@param prefix string key= prefix to prepend to results
---@param arglead string
---@return string[]?
local function resolve_value_completions(value, prefix, arglead)
  local val_part = arglead:sub(#prefix + 1)
  local results

  if type(value) == 'string' then
    results = vim.fn.getcompletion(val_part, value, 1)
  elseif type(value) == 'function' then
    results = value()
  elseif type(value) == 'table' then
    results = value
  elseif value == true then
    return nil
  end

  if not results then
    return nil
  end

  return vim
    .iter(results)
    :filter(function(v) return v:find(val_part, 1, true) end)
    :map(function(v) return prefix .. v end)
    :totable()
end

---@param spec cmd.complete.spec|fun(...): cmd.complete.spec
---@return cmd.complete
local function wrap_completion(spec, ...)
  local get
  if vim.is_callable(spec) then
    get = mia.partial(spec, ...)
  else
    get = function() return spec end
  end

  return function(ArgLead, CmdLine, CursorPos)
    local completions = get(ArgLead, CmdLine, CursorPos)
    if not completions then
      return {}
    end

    local arr, dict = mia.tbl.splitarr(completions)

    local key = ArgLead:match('^(%w+)=')
    if key and dict[key] then
      local results = resolve_value_completions(dict[key], key .. '=', ArgLead)
      return results or {}
    end

    local results = {}
    for _, v in ipairs(arr) do
      if v:find(ArgLead, 1, true) then
        table.insert(results, v)
      end
    end
    for k in pairs(dict) do
      local candidate = k .. '='
      if candidate:find(ArgLead, 1, true) then
        table.insert(results, candidate)
      end
    end
    table.sort(results)
    return results
  end
end

local parse_cmd

---@param raw_subcommands mia.command.subcommands
---@param static_parsed? table<string, mia.command> pre-parsed static subcommands
---@return table<string, mia.command>
local function resolve_subcommands(raw_subcommands, static_parsed)
  if static_parsed and not raw_subcommands[1] then
    return static_parsed
  end

  if vim.is_callable(raw_subcommands) then
    local dynamic = raw_subcommands()
    local resolved = {}
    for name, subspec in pairs(dynamic) do
      resolved[name] = parse_cmd(subspec)
    end
    return resolved
  end

  local resolved = {}
  if static_parsed then
    for k, v in pairs(static_parsed) do
      resolved[k] = v
    end
  end
  local dynamic_fn = raw_subcommands[1]
  if vim.is_callable(dynamic_fn) then
    local dynamic = dynamic_fn()
    for name, subspec in pairs(dynamic) do
      if not resolved[name] then
        resolved[name] = parse_cmd(subspec)
      end
    end
  end
  return resolved
end

---@param opts mia.command.create
---@return mia.command
parse_cmd = function(opts)
  if type(opts) ~= 'table' then
    opts = { opts }
  else
    opts = vim.deepcopy(opts)
  end

  if type(opts.complete) == 'string' then
    local complete_type = opts.complete --[[@as string]]
    opts.complete = function(ArgLead, CmdLine, CursorPos) return vim.fn.getcompletion(ArgLead, complete_type, 1) end
  elseif type(opts.complete) == 'table' or (type(opts.complete) ~= 'function' and vim.is_callable(opts.complete)) then
    opts.complete = wrap_completion(opts.complete)
  end

  -- TODO: wrap default args if not called from command
  -- fix nargs, range, count, register

  local cmd = opts[1] or opts.callback or opts.command
  if cmd and type(cmd) == 'string' then
    cmd = parse_string_cmd(cmd)
  end

  -- local bangfunc = opts.bang and type(opts.bang) == 'function' and opts.bang

  if opts.subcommands then
    local raw_subcommands = opts.subcommands
    local is_dynamic = vim.is_callable(raw_subcommands)

    local static_parsed
    if not is_dynamic then
      static_parsed = {}
      for name, subspec in pairs(raw_subcommands) do
        if type(name) == 'string' then
          static_parsed[name] = parse_cmd(subspec)
        end
      end
    end

    local original_cmd = cmd
    ---@type cmd.callback
    cmd = function(o)
      local prefix = o.fargs[1]
      if not prefix then
        if original_cmd then
          original_cmd(o)
        end
        return
      end

      local subcommands = resolve_subcommands(raw_subcommands, static_parsed)
      if subcommands[prefix] then
        table.remove(o.fargs, 1)
        o.args = o.args:match('^%s*' .. vim.pesc(prefix) .. '%s*(.*)')
        subcommands[prefix].cb(o)
      elseif original_cmd then
        original_cmd(o)
      end
    end

    local og_complete = opts.complete
    ---@type cmd.complete
    opts.complete = function(ArgLead, CmdLine, CursorPos)
      local subcommands = resolve_subcommands(raw_subcommands, static_parsed)

      -- strip command name from cmdline
      local split_cmdline = vim.split(CmdLine:sub(1, CursorPos), '%s')
      table.remove(split_cmdline, 1)

      CursorPos = CursorPos - #CmdLine
      CmdLine = table.concat(split_cmdline, ' ')
      CursorPos = CursorPos + #CmdLine

      if not CmdLine:sub(1, CursorPos):match('%s') then
        -- completing the subcommand name
        local subcmds = vim
          .iter(vim.tbl_keys(subcommands))
          :filter(function(sub) return sub:find(ArgLead, 1, true) end)
          :totable()
        if #subcmds > 0 then
          return subcmds
        end
      else
        -- completing subcommand arguments
        local args = vim.split(CmdLine, '%s')
        local subcmd = subcommands[args[1]]
        if subcmd and subcmd.opts.complete then
          local ws, cmdline = CmdLine:match('^%S+(%s+)(.*)$')
          return subcmd.opts.complete(ArgLead, cmdline, CursorPos - #args[1] - #ws)
        end
      end

      if og_complete then
        return og_complete(ArgLead, CmdLine, CursorPos)
      end
      return {}
    end
  end

  local bang = opts.bang and true
  local parsed_opts = mia.tbl.rm(opts, 1, 'command', 'callback', 'bang', 'subcommands')
  opts.bang = bang

  return { cb = cmd, opts = parsed_opts, buf = opts.buffer }
end

---@param name string
---@param opts mia.command.def
local function create(name, opts)
  -- script name of calling command
  -- if in watched dir, then register it for reload
  local cmd = parse_cmd(opts)
  cmd.cb = wrap_cmd(cmd.cb)
  if not cmd.buf then
    vim.api.nvim_create_user_command(name, cmd.cb, cmd.opts)
  else
    vim.api.nvim_buf_create_user_command(cmd.buf, name, cmd.cb, cmd.opts)
  end
end

return setmetatable({
  create = create,
  parse = parse_cmd,
  get = get_cmd,
  wrap_complete = wrap_completion,
}, {
  __call = function(_, name, opts) create(name, opts) end,
})
