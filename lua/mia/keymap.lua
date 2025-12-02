local function dotrepeat(rhs, lhs)
  if type(rhs) == 'string' then
    assert(lhs)
    return ('%s<Cmd>call repeat#set(%s, v:count)<Cr>'):format(rhs, lhs)
  end
  return function()
    vim.fn['repeat#set'](lhs, vim.v.count)
    return rhs()
  end
end

---@alias mia.keymap { mode: string, lhs: string, rhs: string|function, opts: table, dotrhs: string|function }

---@param spec table
---@param opts? table
---@return fun():mia.keymap
local function parse(spec, opts)
  return coroutine.wrap(function()
    local keymap, _opts = mia.tbl.splitarr(spec)
    opts = vim.tbl_extend('force', opts or {}, _opts)

    if type(keymap[1]) ~= 'table' then
      local lhs = keymap[1] or mia.tbl.pop(opts, 'lhs')
      local rhs = keymap[2] or mia.tbl.pop(opts, 'rhs')
      coroutine.yield({
        mode = opts.mode or 'n',
        lhs = lhs,
        rhs = rhs,
        dotrhs = opts.dotrepeat and dotrepeat(rhs, lhs),
        opts = mia.tbl.rm(opts, 'mode', 'dotrepeat'),
      })
    else
      for _, map in ipairs(keymap) do
        for km in parse(map, opts) do
          coroutine.yield(km)
        end
      end
    end
  end)
end

local function do_keymap(spec, opts)
  for m in parse(spec, opts) do
    local ok, err = pcall(vim.keymap.set, m.mode, m.lhs, m.dotrhs or m.rhs, m.opts)
    if not ok then
      mia.error('Failed to set keymap: %s\n%s', vim.inspect(m, { newline = '', indent = '' }), err)
    end
  end
end

local function get(mode, name)
  if not name then
    name = mode
    mode = 'n'
  end
  local km = vim.fn.maparg(name, mode:sub(1, 1), mode:sub(2) == 'a', true) --[[@as table]]
  return km.lhs and parse(km)() or nil
end

local function remap(spec)
  -- hate this, but it works for now
  for map in parse(spec) do
    local mode = map.mode
    local m, a = mode:sub(1, 1), mode:sub(2) == 'a'
    local km = vim.fn.maparg(map.rhs --[[@as string]], m, a, true)
    vim.keymap.set(mode, map.lhs, '<Nop>')
    local newkm = vim.fn.maparg(map.lhs, m, a, true)
    km.lhs = newkm.lhs
    km.lhsraw = newkm.lhsraw
    km.lhsrawalt = newkm.lhsrawalt
    vim.fn.mapset(km) ---@diagnostic disable-line: param-type-mismatch
    vim.keymap.del(mode, map.rhs --[[@as string]])
  end
end

return setmetatable({ get = get, remap = remap, parse = parse, set = do_keymap }, {
  __index = function(M, modes)
    return function(spec)
      return M({ spec, mode = vim.iter(modes:gmatch('.')):totable() })
    end
  end,

  __call = function(_, spec)
    do_keymap(spec)
  end,
})
