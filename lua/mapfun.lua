---@alias keymap.mode 'n' | 'v' | 's' | 'x' | 'o' | 'i' | 'l' | 'c' | 't' | '!' | '' | 'ia' | 'ca' | '!a'

---@class keymap.opts
---@field buffer? boolean
---@field silent? boolean
---@field nowait? boolean
---@field desc? string
---@field expr? boolean
---@field remap? boolean
---@field noremap? boolean
---@field replace_termcodes? boolean

---@class mapfun.opts: keymap.opts
---@field dotrepeat? boolean

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

---@param mode keymap.mode
---@param lhs string
---@param rhs string | function
---@param opts mapfun.opts
local function set_with_repeat(mode, lhs, rhs, opts)
  opts = opts or {}
  local add_repeat = opts.dotrepeat
  opts.dotrepeat = nil
  if add_repeat then
    rhs = dotrepeat(rhs, lhs)
  end
  vim.keymap.set(mode, lhs, rhs, opts)
end

---@alias keymap.func fun(lhs: string, rhs: string | function, opts: keymap.opts | mapfun.opts)

-- stylua: ignore start
---@type table<keymap.mode, keymap.func>
local M = {
  ia = function(...) vim.keymap.set('ia', ...) end,
  ca = function(...) vim.keymap.set('ca', ...) end,
  ['!a'] = function(...) vim.keymap.set('!a', ...) end,
  [''] = function(...) set_with_repeat('', ...) end,
}

for mode in ('nvsxoilct!'):gmatch('.') do
  M[mode] = function(...) set_with_repeat(mode, ...) end
end
-- stylua: ignore end

-- TODO indexing buffer stuff?

setmetatable(M, {
  ---@param tbl table
  ---@param modes keymap.mode | keymap.mode[]
  ---@param opts mapfun.opts
  ---@return keymap.func ...
  __call = function(tbl, modes, opts)
    local funcs = {}
    if type(modes) == 'string' then
      modes = { modes }
    end
    for _, mode in ipairs(modes) do
      local func = tbl[mode]

      if opts then
        func = function(lhs, rhs, new_opts)
          if type(new_opts) == 'table' then
            opts = vim.tbl_extend('force', opts, new_opts)
          end
          tbl[mode](lhs, rhs, opts)
        end
      end

      funcs[#funcs + 1] = func
    end
    return unpack(funcs)
  end,
})

return M
