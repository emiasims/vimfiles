local fold = { queries = {} }

local ts = vim.treesitter

ts.set_query('org', 'fold', [[(section) @fold]])
ts.set_query(
  'python',
  'fold',
  [[
(module (decorated_definition (function_definition (block))) @fold)
(module (function_definition (block)) @fold)
(class_definition (block)) @fold
(class_definition (block [ (decorated_definition (function_definition (block))) (function_definition (block)) ] @fold (trimnls! @fold)))
]]
)
ts.set_query(
  'lua',
  'fold',
  [[
(function_declaration) @fold
]]
)

function fold.trim_newlines(match, _, bufnr, pred, metadata)
  -- TODO max newlines
  local node = match[pred[2]]
  local start_line, start_col, end_line, end_col = node:range()
  while vim.api.nvim_buf_get_lines(bufnr, end_line, end_line + 1, false)[1] == '' do
    end_line = end_line - 1
  end
  metadata.content = {start_line, start_col, end_line, end_col}
  -- metadata[node:id()].content = {start_line, start_col, end_line, end_col}
end
-- handler(match, pattern, bufnr, predicate, metadata)
vim.treesitter.query.add_directive('trimnls!', fold.trim_newlines, true)

function fold.queryexpr(lnum)
  -- start = vim.fn.line(lnum)-1
  local start, stop = lnum - 1, lnum
  local root = ts.get_parser(0):parse()[1]:root()
  local folds, foldlevel = {}, 0
  local r1, r2, _
  local qu = ts.get_query(vim.o.filetype, 'fold')
  for _, node, _ in qu:iter_captures(root, 0, start, stop) do
    if vim.o.filetype == 'org' then
      -- TODO fix the stupid parser
      if foldlevel == 1 then
        folds[vim.fn.prevnonblank(r2) - 1] = '<2'
      end
    else
      if foldlevel == 1 then
        folds[vim.fn.prevnonblank(r2)] = '<2'
      end
    end
    r1, _, r2, _ = node:range()
    foldlevel = foldlevel + 1
    folds[r1] = '>' .. foldlevel
  end
  return folds[start] or '='
end

return fold
