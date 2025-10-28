local ts = vim.treesitter

local M = { default = ts.foldexpr }

local query = setmetatable({
  strings = {
    lua = '(chunk (comment) @fold (#lua-match? @fold "^%-%-%-"))',
    python = '(module (comment) @fold)',
    vimdoc = '(block (line (h1))) @fold (block (line (h2))) @fold (block (line (tag))) @fold',
    org = '(body (_ (_ (checkbox) (_)* contents: (_ (_ (checkbox)))) @fold))',
  },
}, {
  __index = function(tbl, key)
    tbl[key] = ts.query.parse(key, tbl.strings[key])
    return tbl[key]
  end,
})

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

function M.lua(bufnr)
  local root = ts.get_parser(bufnr, 'lua'):parse()[1]:root()
  local lines = {}
  local line, col
  for _, node, _ in query.lua:iter_captures(root, bufnr, 0, -1) do
    line, col = node:start()
    if col == 0 or vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]:sub(col):match '^%s*$' then
      lines[#lines + 1] = line
    end
  end
  return group_consecutive(lines)
end

function M.python(bufnr)
  local root = ts.get_parser(bufnr, 'python'):parse()[1]:root()
  local lines = {}
  local line, col
  for _, node, _ in query.python:iter_captures(root, bufnr, 0, -1) do
    line, col = node:start()
    if col == 0 or vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]:sub(col):match '^%s*$' then
      lines[#lines + 1] = line
    end
  end
  return group_consecutive(lines)
end

-- list of { startLine = lnum, endLine = lnum }
return M
