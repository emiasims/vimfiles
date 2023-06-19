local ts = vim.treesitter

local expr = {}

local function group_consecutive(lines)
  local start, last, groups = lines[1], lines[1], {}
  vim.iter(lines):skip(1):each(function(lnum)
    if lnum - last > 1 and last > start then
      groups[#groups + 1] = { startLine = start, endLine = last }
    end
    if lnum - last > 1 then
      start = lnum
    end
    last = lnum
  end)
  if start and last and last - start > 0 then
    groups[#groups + 1] = { startLine = start, endLine = last }
  end
  return groups
end

local fold_string = [[(chunk (comment) @fold (#lua-match? @fold "^---"))]]
local fold_query
function expr.lua(bufnr)
  fold_query = fold_query or ts.query.parse('lua', fold_string)
  local root = ts.get_parser(bufnr, 'lua'):parse()[1]:root()
  local lines = {}
  for _, node, _ in fold_query:iter_captures(root, bufnr, 0, -1) do
    lines[#lines + 1] = node:start()  -- single line captures only
  end
  return group_consecutive(lines)
end

-- used in lua/plugins/ufo
return setmetatable(expr, { __index = function() return function() return {} end end })
