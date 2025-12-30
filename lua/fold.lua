local ts = vim.treesitter
local api = vim.api

local M = {}
local Cache = {}
M._cache = Cache

function M.highlights(lnum, bufnr)
  vim.validate('lnum', lnum, 'number')
  vim.validate('bufnr', bufnr, 'number')
  return mia.highlight.extract(bufnr, lnum)
end

---@param foldtext { [1]: string, [2]?: string|string[] }[][] Chunks
function M.add_suffix(foldtext)
  if type(foldtext) == 'string' then
    foldtext = { { foldtext, 'Folded' } }
  end
  table.insert(foldtext, { ' ⋯ ', 'Comment' })

  local suffix = ('%s lines %s'):format(vim.v.foldend - vim.v.foldstart, ('|'):rep(vim.v.foldlevel))
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local vtWidth = 0
  for _, chunk in ipairs(foldtext) do
    vtWidth = vtWidth + vim.fn.strdisplaywidth(chunk[1])
  end

  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local target = wininfo.width - wininfo.textoff - sufWidth

  if vtWidth < target then
    suffix = (' '):rep(target - vtWidth) .. suffix
  end
  table.insert(foldtext, { suffix, 'Comment' })
  return foldtext
end

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
    local foldtext = vim.b[bufnr]._foldtext
    if foldtext then
      cache[lnum] = M.add_suffix(foldtext(lnum, bufnr))
    else
      cache[lnum] = M.add_suffix(M.highlights(lnum, bufnr))
    end
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
_G.fold = M

mia.augroup('fold', {
  FileType = {
    pattern = '*',
    callback = function(ev)
      local ft = ev.match
      local ffoldtext = api.nvim_get_runtime_file(vim.fs.joinpath('fold', ft, 'text.lua'), false)[1]
      if ffoldtext then
        vim.b[ev.buf]._foldtext = dofile(ffoldtext) -- TODO cache
      end

      local ffoldexpr = api.nvim_get_runtime_file(vim.fs.joinpath('fold', ft, 'expr.lua'), false)[1]
      if ffoldexpr then
        vim.b[ev.buf]._foldexpr = dofile(ffoldexpr)
      end
    end,
  },
})

return M
