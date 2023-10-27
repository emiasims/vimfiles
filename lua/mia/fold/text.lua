local M = {}

local ts = vim.treesitter
local api = vim.api
function M.tsfoldtext(lnum, bufnr)
  local foldstart = lnum or vim.v.foldstart
  local bufnr = bufnr or api.nvim_get_current_buf()

  ---@type boolean, LanguageTree
  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok then
    return vim.fn.foldtext()
  end

  local query = ts.query.get(parser:lang(), 'highlights')
  if not query then
    return vim.fn.foldtext()
  end

  local tree = parser:parse { foldstart - 1, foldstart }[1]

  local line = api.nvim_buf_get_lines(bufnr, foldstart - 1, foldstart, false)[1]
  if not line then
    return vim.fn.foldtext()
  end

  -- local highlights = {}
  -- local ids_per_char = {}
  -- for i = 1, #line do
  --   ids_per_char[i] = {}
  -- end

  local highlights = { { id = 1, group = '@folded', priority = 1, range = { 0, #line } } }
  local ids_per_char = {}
  for i = 1, #line do
    ids_per_char[i] = { 1 }
  end

  for id, node, metadata in query:iter_captures(tree:root(), 0, foldstart - 1, foldstart) do
    local name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()

    local priority = tonumber(metadata.priority or vim.highlight.priorities.treesitter)

    if start_row <= foldstart - 1 and end_row >= foldstart - 1 then
      start_col = start_row < foldstart - 1 and 0 or start_col
      end_col = end_row > foldstart - 1 and #line or end_col

      local hl = {
        id = #highlights + 1,
        conceal = metadata.conceal,
        group = '@' .. name,
        priority = priority,
        range = { start_col, end_col },
      }
      highlights[hl.id] = hl

      for i = start_col + 1, end_col do
        table.insert(ids_per_char[i], hl.id)
      end
    end
  end

  -- split into chunks with uniform ranges
  local chunks = {}
  local current = { ids = ids_per_char[1], range = { 1, 1 } }
  for i = 2, #line do
    local ids = ids_per_char[i]
    if vim.deep_equal(current.ids, ids) then
      current.range[2] = i
    else
      table.insert(chunks, current)
      current = { ids = ids, range = { i, i } }
    end
  end
  if current then
    table.insert(chunks, current)
  end

  local result = {}
  for _, chunk in ipairs(chunks) do
    local hls = {}
    for ix, id in ipairs(chunk.ids) do
      hls[ix] = highlights[id]
    end

    table.sort(hls, function(a, b)
      return a.priority < b.priority or (a.priority == b.priority and a.id < b.id)
    end)

    local conceal
    for ix, hl in ipairs(hls) do
      conceal = conceal or hl.conceal
      hls[ix] = hl.group
    end
    if #hls == 0 then
      hls = { '@folded' }
    end

    table.insert(result, { conceal or line:sub(chunk.range[1], chunk.range[2]), hls })
  end

  return result
end

function M.default(foldtext)
  if not foldtext then
    foldtext = M.tsfoldtext()
  end

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
  local width = nvim.win_get_width(0) - 4
  local target = width - sufWidth - ((vim.o.number and 1 or 0) * vim.o.numberwidth)
  if vtWidth < target then
    suffix = (' '):rep(target - vtWidth) .. suffix
    table.insert(foldtext, { suffix, 'Comment' })
  end
  return foldtext
end

function M.org()
  local foldtext = M.default()

  local heart = vim.iter(foldtext):find(function(t) return t[1] == '❤' end)
  if heart then
    heart[1] = '❥'
  end

  return foldtext
end

function M.python()
  local foldtext = M.tsfoldtext()
  local bufnr = nvim.get_current_buf()
  local text = vim.fn.getline(vim.v.foldstart)  --[[@as string]]

  -- Process decorated functions
  if text:match '^%s*@' then
    local pos = { vim.v.foldstart - 1, #vim.fn.getbufline(bufnr, vim.v.foldstart)[1] - 1 }
    local decorator = vim.treesitter.get_node { bufnr = bufnr, pos = pos }
    while decorator and decorator:type() ~= 'decorated_definition' do
      decorator = decorator:parent()
    end
    if not decorator then
      return M.default()
    end

    local line = decorator:field 'definition'[1]:start()
    local new_foldtext = M.tsfoldtext(line + 1)
    while #new_foldtext > 0 and new_foldtext[1][1]:match '^%s+$' do
      table.remove(new_foldtext, 1)
    end
    new_foldtext[1][1] = ' ' .. new_foldtext[1][1]
    vim.list_extend(foldtext, new_foldtext)
  end

  return M.default(foldtext)
end

return M
