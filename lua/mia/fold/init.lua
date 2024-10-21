local M = {}
local Cache = {}
M._cache = Cache

-- would love this to be cached with vim.treesitter._fold
M.text = function(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  bufnr = bufnr ~= 0 and bufnr or vim.api.nvim_get_current_buf()

  if not Cache[bufnr] then
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

  local cache = Cache[bufnr] or {}
  if not cache[lnum] then
    local text = require('mia.fold.text')
    local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
    local fn = text[ft] or text.default
    cache[lnum] = fn(lnum, bufnr)
  end
  Cache[bufnr] = cache
  return cache[lnum] or ''
end

M.expr = function()
  -- mia.runtime('fold', ft)
  local expr = require('mia.fold.expr')
  local ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
  if expr[ft] then
    return expr[ft]()
  end
  return expr['default']()
end

return M
