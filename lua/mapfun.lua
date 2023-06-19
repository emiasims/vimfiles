local M = {
  c = function(...) vim.keymap.set('c', ...) end,
  x = function(...) vim.keymap.set('x', ...) end,
  n = function(...) vim.keymap.set('n', ...) end,
  t = function(...) vim.keymap.set('t', ...) end,
  o = function(...) vim.keymap.set('o', ...) end,
  i = function(...) vim.keymap.set({ 'i', 's' }, ...) end,
  m = function(...) vim.keymap.set({ 'n', 'x', 'o' }, ...) end,
}

setmetatable(M, {
  __call = function(tbl, chars, opts)
    local funcs = {}
    for c in chars:gmatch '.' do
      local func = tbl[c]
      if opts then
        func = function(lhs, rhs, new_opts)
          if type(new_opts) == 'table' then
            opts = vim.tbl_extend('force', opts, new_opts)
          end
          tbl[c](lhs, rhs, opts)
        end
      end
      funcs[#funcs + 1] = func
    end
    return unpack(funcs)
  end,
})

return M
