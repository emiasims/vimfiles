local expr = { queries = {} }

local ts = vim.treesitter

ts.set_query('org', 'fold', [[
(document  (section) @fold (#offset! @fold 0 0 -1 0))
((section (section) @fold (section) . ) (#offset! @fold 0 0 -1 0))
((section (section) @fold . ) (#offset! @fold 0 0 -1 0) (#trim-nls! @fold))
(property_drawer . (property)) @fold]])

ts.set_query(
  'python',
  'fold',
  [[
(module (decorated_definition (function_definition (block))) @fold (#eat-nls! @fold 1))
(module (function_definition (block)) @fold (#eat-nls! @fold 1))
((class_definition (block)) @fold (#eat-nls! @fold 1))
(class_definition (block [ (decorated_definition (function_definition (block))) (function_definition (block)) ] @fold (eat-nls! @fold) [ (decorated_definition (function_definition (block))) (function_definition (block)) ] .))
(class_definition (block [ (decorated_definition (function_definition (block))) (function_definition (block)) ] @fold .))
]]
)
ts.set_query(
  'lua',
  'fold',
  [[
(function_declaration) @fold
(table_constructor (field (function_definition) @fold))
]]
)

function expr.eat_newlines(match, _, bufnr, pred, metadata)
  -- handler(match, pattern, bufnr, predicate, metadata)
  local capture_id = pred[2]
  local max = pred[3] and tonumber(pred[3])
  local node = match[capture_id]
  local start_line, start_col, end_line, end_col = node:range()

  if not metadata[capture_id] then
    metadata[capture_id] = {}
  end
  metadata = metadata[capture_id]

  if metadata.range then
    start_line, start_col, end_line, end_col = unpack(metadata.range)
  end

  local eaten = 0
  while vim.api.nvim_buf_get_lines(bufnr, end_line+1, end_line + 2, false)[1] == '' do
    eaten = eaten + 1
    if max and eaten > max then
      break
    end
    end_line = end_line + 1
  end

  metadata.range = { start_line, start_col, end_line, end_col }
  -- metadata[node:id()].content = {start_line, start_col, end_line, end_col}
end

function expr.trim_newlines(match, _, bufnr, pred, metadata)
  -- handler(match, pattern, bufnr, predicate, metadata)
  local capture_id = pred[2]
  local node = match[capture_id]
  local start_line, start_col, end_line, end_col = node:range()

  if not metadata[capture_id] then
    metadata[capture_id] = {}
  end
  metadata = metadata[capture_id]

  if metadata.range then
    start_line, start_col, end_line, end_col = unpack(metadata.range)
  end

  while vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1] == '' do
    end_line = end_line - 1
  end

  metadata.range = { start_line, start_col, end_line, end_col }
  -- metadata[node:id()].content = {start_line, start_col, end_line, end_col}
end
vim.treesitter.query.add_directive('trim-nls!', expr.trim_newlines, true)
vim.treesitter.query.add_directive('eat-nls!', expr.eat_newlines, true)

local fold_cache = {}

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
  local qu = ts.get_query(vim.o.filetype, 'fold')
  if not start then
    start, stop = 0, -1
  elseif not stop then
    start, stop = 0, start
  end
  local open, close
  -- local cmds = { 'normal! %s' } -- TODO zD range? update on_treechanged
  -- local foldcmd = '%s,%sfold'
  local cmds = {}
  for id, node, md in qu:iter_captures(root, 0, start, stop) do
    if md[id] and md[id].range then
      open, _, close, _ = unpack(md[id].range)
    else
      open, _, close, _ = node:range()
    end

    cmds[#cmds + 1] = { cmd = 'fold', range = { open + 1, close + 1 } }
    -- cmds[#cmds + 1] = { cmd = 'fold', range = { open + 1, close } }
    -- cmds[#cmds + 1] = foldcmd:format(open + 1, close)
  end

  table.sort(cmds, fold_cmp)
  -- a, b, if a within b, then line number

  table.insert(cmds, 1, { cmd = 'normal', bang = true, args = { 'zE' } })

  return cmds
end

function expr.calculate_foldexpr(root)
  -- local sub1 = vim.o.filetype == 'org'
  local folds = {}
  local qu = ts.get_query(vim.o.filetype, 'fold')
  local open, close
  for id, node, md in qu:iter_captures(root, 0, 0, -1) do
    if md[id] and md[id].range then
      open, _, close, _ = unpack(md[id].range)
    else
      open, _, close, _ = node:range()
    end
    folds[open] = folds[open] or { opens = 0, closes = 0 }
    folds[close] = folds[close] or { opens = 0, closes = 0 }
    folds[open].opens = folds[open].opens + 1
    folds[close].closes = folds[close].closes + 1
  end

  -- using tbl_keys creates a table so I can modify folds
  local lines = vim.tbl_keys(folds)
  table.sort(lines) -- necessary!
  local foldlevel = 0
  local closes
  for _, ln in ipairs(lines) do
    foldlevel = foldlevel + folds[ln].opens
    closes = folds[ln].closes
    if folds[ln].opens > 0 then
      folds[ln] = '>' .. foldlevel
    else
      folds[ln] = '<' .. (foldlevel - closes + 1)
    end
    foldlevel = foldlevel - closes
  end
  return folds
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
  return fold_cache[buf].folds[lnum - 1] or '='
end

function expr.update_manual(start, stop)
  for _, cmd in ipairs(expr.calculate_manual(start, stop)) do
    vim.api.nvim_cmd(cmd, {})
  end
end

return expr
