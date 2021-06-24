M = {queries = {}}

local ts = vim.treesitter

ts.set_query('org', 'fold', [[(section) @fold]])
ts.set_query('python', 'fold', [[
(function_definition (block)) @fold
(class_definition (block)) @fold
]])
ts.set_query('lua', 'fold', [[
(function) @fold
(local_function) @fold
]])

function M.queryexpr(lnum)
  -- start = vim.fn.line(lnum)-1
  local start, stop, folds, foldlevel = lnum - 1, lnum
  local root = ts.get_parser(bufnr or 0, lang):parse()[1]:root()
  local folds, foldlevel = {}, 0
  local r1, r2, _
  local qu = ts.get_query(vim.o.filetype, 'fold')
  for _, node, _ in qu:iter_captures(root, 0, start, stop) do
    if vim.o.filetype == 'org' then
      -- TODO fix the stupid parser
      if foldlevel == 1 then folds[vim.fn.prevnonblank(r2) - 1] = "<2" end
    else
      if foldlevel == 1 then folds[vim.fn.prevnonblank(r2)] = "<2" end
    end
    r1, _, r2, _ = node:range()
    foldlevel = foldlevel + 1
    folds[r1] =  ">"..foldlevel
  end
  return folds[start] or '='
end

return M
