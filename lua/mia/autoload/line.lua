---@alias line.func fun(opts: table): string|{[1]: string, [2]: string}[]
---@alias line.render string|line.func
---@alias line.segment string|line.func|{[1]: string, [2]: string}|{[1]: line.func, [2]: string|table}

local function cfmt(text, hl)
  if not text then
    return ''
  elseif not hl then
    hl, text = text, ''
  end
  return ('%%#%s#%s'):format(hl, text)
end

---@param segment line.segment
---@return line.func
local function normalize(segment)
  if type(segment) == 'function' then
    return segment
  elseif type(segment) == 'string' then
    return function()
      return segment
    end
  elseif type(segment[1]) == 'string' then
    local const = cfmt(segment[1], segment[2])
    return function()
      return const
    end
  end

  local func, hl = unpack(segment)
  return function(opts)
    return { func(opts), hl }
  end
end

local function eval_segment(segment, opts)
  local s = true
  local v = segment(opts)
  if not s then
    vim.notify_once(v)
  elseif type(v) == 'table' then
    return cfmt(unpack(v))
  end
  return v and v or ''
end

local function compile(spec)
  local segments = {}
  for i, v in ipairs(spec) do
    segments[i] = normalize(v)
  end

  return function(opts)
    return vim
      .iter(segments)
      :map(function(segment)
        return eval_segment(segment, opts)
      end)
      :totable()
  end
end

local function build(spec)
  local setup = spec.setup
  local teardown = spec.teardown
  spec = spec or {}
  local sep = spec.sep
  local front = spec.front or ''
  local back = spec.back or ''

  local eval = compile(spec)

  local last_success = 'Tabline generation failed'
  return function(_opts)
    local ok, ret = pcall(function()
      local opts = setup(_opts)
      local ret = front .. table.concat(eval(opts), sep) .. back
      if teardown then
        teardown(opts)
      end
      return ret
    end)
    last_success = ok and ret or last_success
    return last_success
  end
end

return {
  eval_segment = eval_segment,
  compile = compile,
  build = build,
  cfmt = cfmt,
}
