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

local function do_keymap(spec, opts)
  local keymap, _opts = mia.tbl.splitarr(spec)
  opts = vim.tbl_extend('force', opts or {}, _opts)

  if type(spec[1]) == 'table' then
    for _, map in ipairs(keymap) do
      do_keymap(map, opts)
    end
  else
    local mode, drep = opts.mode or 'n', opts.dotrepeat

    if drep then
      spec[2] = dotrepeat(spec[2], spec[1])
    end

    opts.mode, opts.dotrepeat = nil, nil

    local ok, err = pcall(vim.keymap.set, mode, spec[1], spec[2], opts)

    if not ok then
      mia.log.error({ 'keymap', mode }, 'lhs = %s, rhs = %s, opts = %s, err = %s', spec[1], spec[2], opts, err)
    else
      mia.log.info({ 'keymap', mode }, 'lhs = %s, rhs = %s, opts = %s', spec[1], spec[2], opts)
    end
  end
end

return setmetatable({}, {
  __index = function(M, modes)
    return function(spec)
      return M({ spec, mode = vim.iter(modes:gmatch('.')):totable() })
    end
  end,

  __call = function(_, spec)
    do_keymap(spec)
  end,
})
