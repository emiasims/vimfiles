---@type table<string, mia.command>
local Commands = setmetatable({}, { __mode = 'v' })

-- TODO buffer or global dictionary?

local function get_cmd(name)
  return name and Commands[name] or Commands
end

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
  ['<bang>'] = function(o)
    return o.bang and '!' or ''
  end,
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

---@param completions string[]|fun(...): string[]
local function wrap_list_completion(completions, ...)
  local get
  if vim.is_callable(completions) then
    get = mia.partial(completions, ...)
  else
    get = function()
      return completions
    end
  end
  return function(ArgLead, CmdLine, CursorPos)
    local options = get()

    if CmdLine:find('%s') or math.huge < CursorPos then
      return {}
    end
    return vim
      .iter(options)
      :filter(function(opt)
        return opt:find(ArgLead, 1, true)
      end)
      :totable()
  end
end

---@param opts mia.command.create
---@return mia.command
local function parse_cmd(opts)
  if type(opts) ~= 'table' then
    opts = { opts }
  else
    opts = vim.deepcopy(opts)
  end

  -- consistent parsing logic required
  if type(opts.complete) == 'string' then
    local complete_type = opts.complete --[[@as string]]
    opts.complete = function(ArgLead, CmdLine, CursorPos)
      return vim.fn.getcompletion(ArgLead, complete_type, 1) -- FIXME
    end
  elseif type(opts.complete) == 'table' then
    opts.complete = wrap_list_completion(opts.complete)
  end

  -- TODO: wrap default args if not called from command
  -- fix nargs, range, count, register

  local cmd = opts[1] or opts.callback or opts.command
  if cmd and type(cmd) == 'string' then
    cmd = parse_string_cmd(cmd)
  end

  -- local bangfunc = opts.bang and type(opts.bang) == 'function' and opts.bang

  if opts.subcommands then
    local subcommands = {}
    for name, subspec in pairs(opts.subcommands) do
      subcommands[name] = parse_cmd(subspec)
    end

    local original_cmd = cmd
    ---@type cmd.callback
    cmd = function(o)
      local prefix = o.fargs[1]
      if prefix and subcommands[prefix] then
        table.remove(o.fargs, 1)
        o.args = o.args:match('^%s*' .. vim.pesc(prefix) .. '%s*(.*)')
        subcommands[prefix].cb(o)
      else
        original_cmd(o)
      end
    end

    local og_complete = opts.complete
    ---@type cmd.complete
    opts.complete = function(ArgLead, CmdLine, CursorPos)
      -- subcommand name completion
      local split_cmdline = vim.split(CmdLine:sub(1, CursorPos), '%s')
      table.remove(split_cmdline, 1) -- command name

      CursorPos = CursorPos - #CmdLine
      CmdLine = table.concat(split_cmdline, ' ')
      CursorPos = CursorPos + #CmdLine

      if not CmdLine:sub(1, CursorPos):match('%s') then
        local subcmds = vim
          .iter(vim.tbl_keys(subcommands))
          :filter(function(sub)
            return sub:find(ArgLead, 1, true)
          end)
          :totable()
        if #subcmds > 0 then
          return subcmds
        end -- fallback to original complete not found
      else -- complete subcommand
        local args = vim.split(CmdLine, '%s')
        local subcmd = subcommands[args[1]]
        if subcmd and subcmd.opts.complete then
          local ws, cmdline = CmdLine:match('^%S+(%s+)(.*)$')
          return subcmd.opts.complete(ArgLead, cmdline, CursorPos - #args[1] - #ws)
        end
      end

      -- fallback
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

-- set false to remove, otherwise overwrites
local function update(name, opts)
  local cmd = get_cmd(name)
  local updates = parse_cmd(opts)

  -- something like this..
  mia.tbl.update(cmd.subcommands, updates.subcommands)
  if updates.callback then
    cmd:set()
  end
end

return setmetatable({
  create = create,
  parse = parse_cmd,
  get = get_cmd,
  wrap_complete = wrap_list_completion,
}, {
  __call = function(_, name, opts)
    create(name, opts)
  end,
})
