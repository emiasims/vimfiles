local expr = { queries = {} }

local fold_cache = {}
local ts = vim.treesitter

local function fold_cmp(a, b)
  if (a.range[1] >= b.range[1] and a.range[2] <= b.range[2]) then
    -- a in b, a before b
    return true
  elseif (b.range[1] >= a.range[1] and b.range[2] <= a.range[2]) then
    -- b in a, b before a
    return false
  end
  -- return the first one
  return a.range[1] < b.range[1]
end

function expr.calculate_manual(start, stop)
  local root = ts.get_parser(0):parse()[1]:root()
  local qu = ts.get_query(vim.o.filetype, 'folds')
  if not start then
    start, stop = 0, -1
  elseif not stop then
    start, stop = 0, start
  end
  local open, close
  local cmds = {}
  for id, node, md in qu:iter_captures(root, 0, start, stop) do
    if md[id] and md[id].range then
      open, _, close, _ = unpack(md[id].range)
    else
      open, _, close, _ = node:range()
    end

    cmds[#cmds + 1] = { cmd = 'fold', range = { open + 1, close + 1 } }
  end

  table.sort(cmds, fold_cmp)
  -- a, b, if a within b, then line number

  table.insert(cmds, 1, { cmd = 'normal', bang = true, args = { 'zE' } })

  return cmds
end

local Folds = {
  __index = function(tbl, lnum)
    tbl[lnum] = { opens = 0, closes = 0 }
    return tbl[lnum]
  end,
}

local FoldVals = {
  __index = function(self, lnum)
    local foldlevel, folds = self._foldlevel, self._folds
    for ln = self._last_lnum, lnum do
      if not folds[ln - 1] then
        self[ln] = foldlevel
      else
        foldlevel = foldlevel + folds[ln - 1].opens
        if folds[ln - 1].opens > 0 then
          self[ln] = '>' .. foldlevel
        else
          self[ln] = foldlevel
        end
        foldlevel = foldlevel - folds[ln - 1].closes
      end
      self._last_lnum = ln
    end
    self._foldlevel = foldlevel
    return self[lnum]
  end
}

function expr.calculate_foldexpr(root)
  -- local sub1 = vim.o.filetype == 'org'
  local folds = setmetatable({}, Folds)
  local qu = ts.get_query(vim.o.filetype, 'folds')
  local open, close
  local allow_zero = vim.b.allow_zero_length_folds

  for _, match, md in qu:iter_matches(root, 0, 0, -1) do
    for id, node in pairs(match) do
      if vim.endswith(qu.captures[id], 'fold') then
        if md[id] and md[id].range then
          open, _, close, _ = unpack(md[id].range)
        else
          open, _, close, _ = node:range()
        end
        if close ~= open or allow_zero then
          folds[open].opens = folds[open].opens + 1
          folds[close].closes = folds[close].closes + 1
        end
      end
    end
  end

  setmetatable(folds, {})

  -- return setmetatable({ _last_lnum = 1, _folds = folds, _foldlevel = 0 }, FoldVals)

  -- using tbl_keys creates a table so I can modify folds
  local foldvals, foldlevel = {}, 0
  for lnum = 1, vim.fn.line('$') do
    if not folds[lnum - 1] then
      foldvals[lnum] = foldlevel
    else
      foldlevel = foldlevel + folds[lnum - 1].opens
      if folds[lnum - 1].opens > 0 then
        foldvals[lnum] = '>' .. foldlevel
      else
        foldvals[lnum] = foldlevel
      end
      foldlevel = foldlevel - folds[lnum - 1].closes
    end
  end
  return foldvals

end

function expr.queryexpr(lnum)
  local buf = vim.api.nvim_get_current_buf()
  if not fold_cache[buf] or not fold_cache[buf].folds or not fold_cache[buf].tree:is_valid() then
    fold_cache[buf] = { tree = ts.get_parser(0) }
    local root = fold_cache[buf].tree:parse()[1]:root()
    if not root:has_error() or not fold_cache[buf].folds then
      fold_cache[buf].folds = expr.calculate_foldexpr(root)
    end
  end
  return fold_cache[buf].folds[lnum]
end

function expr.update_manual(start, stop)
  for _, cmd in ipairs(expr.calculate_manual(start, stop)) do
    vim.api.nvim_cmd(cmd, {})
  end
end

return expr
