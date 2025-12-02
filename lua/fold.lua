local M = {}
local Cache = {}
M._cache = Cache

-- would love this to be cached with vim.treesitter._fold
function M.text(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  bufnr = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()

  if not Cache[bufnr] then
    Cache[bufnr] = {}
    vim.api.nvim_buf_attach(bufnr, false, {
      on_bytes = function(_, _, _, sr, _, _, old_er, _, _, new_er)
        if not Cache[bufnr] then
          return
        end

        local shift = new_er - old_er
        old_er = sr + old_er + 1
        new_er = sr + new_er + 1

        local shifts = {}
        for line in pairs(Cache[bufnr]) do
          if sr <= line and line <= old_er then
            Cache[bufnr][line] = nil
          end

          if shift > 0 and line > old_er then
            shifts[line] = line + shift
          end
        end

        for old, new in pairs(shifts) do
          Cache[bufnr][new], Cache[bufnr][old] = Cache[bufnr][old], nil
        end
      end,

      on_detach = function()
        Cache[bufnr] = nil
      end,
    })
  end

  local cache = Cache[bufnr]
  if not cache[lnum] then
    local text = require('mia.fold.text')
    local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
    local fn = text[ft] or text.default
    cache[lnum] = fn(lnum, bufnr)
  end
  return cache[lnum] or '...'
end

function M.expr()
  -- mia.runtime('fold', ft)
  local expr = require('mia.fold.expr')
  local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
  if expr[ft] then
    return expr[ft]()
  end
  return expr['default']()
end

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldtext = 'v:lua.fold.text()'
mia.keymap({
  'zx',
  function()
    local bn = vim.api.nvim_get_current_buf()
    local expr = require('vim.treesitter._fold').foldexpr
    local foldCache = mia.debug.get_upvalue('foldinfos', expr)
    Cache[bn] = nil
    foldCache[bn] = nil
    return 'zx'
  end,
  expr = true,
  desc = 'Clear fold cache and recompute folds as normal',
})
fold = M

return M
